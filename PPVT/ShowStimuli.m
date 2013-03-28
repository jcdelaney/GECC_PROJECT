%Given a run structure, display the trials for that run

function [success, num_fail] = ShowStimuli(TrialList, varargin)
success = 1;

% globals
global WINDOW % Window ID for Screen
global SUBJECT
global SESSION
global LOGID % file identifer of the log file
global NETSTATION
global START_TIME
global CURRENT_RUN
global CURRENT_BLOCK
global NUM_TRIALS % keeps track of trial numbers
global DEBUG % 1 if using print lines instead of Screen calls, 0 otherwise
global STIM_DURATION % the duration (sec) of the response for each trial
global FEEDBACK_DURATION % the duration (sec) of the feedback for each trial
global RESP_DURATION % the duration (sec) of the feedback for each trial
global ISI % the duration (sec) of the ISI
global IMAGE_FOLDER
global AUDIO_FOLDER
global EVENT
global ABORT
global BUTTON1
global BUTTON2

ResponseMode = (nargin > 1);

if isempty(LOGID)
    LOGID = fopen([num2str(SUBJECT),'_',num2str(SESSION),'_ShowStimLog.txt'],'w');
end

num_fail = 0;

% === 
% load isi image
% ===
ISIImage = [IMAGE_FOLDER,filesep,'isi.jpg'];

try
    ISIPicture = imread(ISIImage, 'jpg');
    ISITexture = Screen('MakeTexture', WINDOW, ISIPicture);
catch ME
    Error = ME.stack(length(ME.stack)-1);
    ErrorInfo = sprintf('[%s|%d]',Error.name, Error.line);
    ExitStudy(sprintf('Problem creating/displaying images\n%s',strcat(ErrorInfo,ME.message)));
    success = 0;
    return
end
            
% inv: Trials 1..t have been shown and responses collected
for t=1:length(TrialList)
    if NETSTATION
        % resynchronize
        NetStation('Synchronize', 2.5);
    end
    % update number of trials
    NUM_TRIALS = NUM_TRIALS + 1;

    % =========
    % "ISI"
    % =========
    try
        if DEBUG
            fprintf('[ShowStimuli] ISI...\n');
            pause(ISI);
            ISIVBL = cputime;
        else
            Screen('DrawTexture', WINDOW, ISITexture);
            Screen('DrawingFinished', WINDOW);
            ISIVBL = Screen('Flip', WINDOW);
        end
    catch ME
        ExitStudy(ME.message);
        success=0;
        return
    end
    % ===
    % load the stimulus image(s)
    % ===
    try
        TrialImage = [IMAGE_FOLDER,filesep,TrialList(t).visualStim,'.jpg'];
        % get trial type
        TrialType = TrialList(t).type;

        if DEBUG
            fprintf('TrialType is %s\n', TrialType);
            fprintf('Loading images... at %10.4f\n', cputime);
            ResponseVBLTime = cputime;
        else
            % load the textures
            StimPicture = imread(TrialImage, 'jpg');
            StimTexture = Screen('MakeTexture', WINDOW, StimPicture);
            if ResponseMode
                PositiveStimulus = [IMAGE_FOLDER,filesep,'correct.jpg'];
                NegativeStimulus = [IMAGE_FOLDER,filesep,'incorrect.jpg'];

                PosPicture = imread(PositiveStimulus, 'jpg');
                PosTexture = Screen('MakeTexture', WINDOW, PosPicture);
                
                NegPicture = imread(NegativeStimulus, 'jpg');
                NegTexture = Screen('MakeTexture', WINDOW, NegPicture);
            end
        end
    catch ME
        Error = ME.stack(length(ME.stack)-1);
        ErrorInfo = sprintf('[%s|%d]',Error.name, Error.line);
        ExitStudy(sprintf('Problem creating/displaying images\n%s',strcat(ErrorInfo,ME.message)));
        success = 0;
        return
    end
    % ===
    % load the stimulus audio
    % ===
    try
        TrialAudio = [AUDIO_FOLDER,filesep,TrialList(t).audioStim,'.wav'];
        
        if DEBUG
            fprintf('Loading audio... at %10.4f\n', cputime);
            ResponseVBLTime = cputime;
        else
            % load wav file
            [y, freq] = wavread(TrialAudio);
            wavedata = y';
            nrchannels = size(wavedata,1);
            
            pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);
            
            buffer = PsychPortAudio('CreateBuffer', pahandle, wavedata);
            PsychPortAudio('FillBuffer', pahandle, wavedata);
        end
    catch ME
        Error = ME.stack(length(ME.stack)-1);
        ErrorInfo = sprintf('[%s|%d]',Error.name, Error.line);
        ExitStudy(sprintf('Problem reading/playing audio\n%s',strcat(ErrorInfo,ME.message)));
        success = 0;
        return
    end
        
    % ======
    % Trial
    % ======
    try
        if DEBUG
            fprintf('[ShowStimuli] Getting response...\n');
            pause(STIM_DURATION);
        else
        % write out info to log file
        TrialTime = GetSecs()-START_TIME;
        fprintf(LOGID,'%d,%d,%s,%s,%s,%.2f\n',CURRENT_RUN,t,TrialType,TrialList(t).audioStim,TrialList(t).visualStim,TrialTime);
            % =============
            % draw texture
            % =============
            if DEBUG
                fprintf('[ShowStimuli] Drawing Texture:%s...\n', TrialName);
                fprintf('[ShowStimuli] Flipping WINDOW...\n');
                StimVBLTime = cputime;
            else
                Screen('DrawTexture', WINDOW, StimTexture);
                Screen('DrawingFinished', WINDOW);
                % display the stimulus image
                [StimVBLTime] = Screen('Flip', WINDOW, ISIVBL + ISI);
                PsychPortAudio('Start', pahandle);

                fprintf('\t[Trial %d: %s]\n',t,TrialType);
        
                Failed=0;
                % send trigger
                switch TrialType
                    case 'Matched Word'
                        [Failed, ErrorMessage] = SendTrigger(EVENT.MatchTrial,StimVBLTime);
                    case 'Mismatched Word'
                        [Failed, ErrorMessage] = SendTrigger(EVENT.MismatchTrial,StimVBLTime);
                end
                if Failed
                    ExitStudy(ErrorMessage);
                    success=0;
                    return
                end
                
                % record response
                ResponseStart = StimVBLTime;
                HasResponded = 0;
                while (GetSecs - ResponseStart < STIM_DURATION) && ~HasResponded
                    [keyIsDown, secs, keyCode ] = KbCheck(-3);
                    WaitSecs(.05);
                    if keyIsDown
                        if sum(keyCode(BUTTON1))
                            HasResponded = 1;
                            Response = 'Matched Word';
                        elseif sum(keyCode(BUTTON2))
                            HasResponded = 1;
                            Response = 'Mismatched Word';
                        elseif sum(keyCode(ABORT))
                            PsychPortAudio('Stop',pahandle);
                            PsychPortAudio('DeleteBuffer',buffer);
                            PsychPortAudio('Close',pahandle);
                            ExitStudy(sprintf('Study aborted by user after run %d, trial %d',CURRENT_RUN,t));
                            success=0;
                            return
                        end
                    end
                end
                
                % if in response mode show positive or negative stimulus
                if HasResponded & ResponseMode
                    Accurate = strcmp(Response,TrialType);
                    if Accurate
                        [Failed ErrorMessage] = SendTrigger(EVENT.Success,secs);
                        fprintf('Subject correctly responded to a %s awareness trial\n',TrialType);
                        Screen('DrawTexture', WINDOW, PosTexture);
                        Screen('DrawingFinished', WINDOW);
                    else
                        [Failed ErrorMessage] = SendTrigger(EVENT.Failure,secs);
                        num_fail = num_fail + 1;
                        fprintf('Subject incorrectly responded to a %s awareness trial\n',TrialType);
                        Screen('DrawTexture', WINDOW, NegTexture);
                        Screen('DrawingFinished', WINDOW);
                    end
                    if Failed
                        ExitStudy(ErrorMessage);
                        success=0;
                        return
                    end
                    ResponseVBLTime = Screen('Flip', WINDOW);
                    % write to log
                    WaitSecs(((ResponseStart + RESP_DURATION) - ResponseVBLTime) + FEEDBACK_DURATION);
                % check for missed response
                elseif ~HasResponded & ResponseMode
                    ExpireTime = GetSecs;
                    % load negative stimulus
                    Screen('DrawTexture', WINDOW, NegTexture);
                    Screen('DrawingFinished', WINDOW);
    
                    [Failed ErrorMessage] = SendTrigger(EVENT.Miss,ExpireTime);
                    num_fail = num_fail + 1;
                    fprintf('[MISS]\n');
                    if Failed
                        ExitStudy(ErrorMessage);
                        success=0;
                        return
                    end
                    % flip screen to clear
                    ResponseVBLTime = Screen('Flip', WINDOW);
                    WaitSecs(FEEDBACK_DURATION);
                end
            end
            PsychPortAudio('Stop',pahandle,1);
            % close texture and audio stream
            Screen('Close',StimTexture);
            PsychPortAudio('DeleteBuffer',buffer);
            PsychPortAudio('Close',pahandle);
            
        end % end if-else DEBUG
    catch ME
        Error = ME.stack(length(ME.stack)-1);
        ErrorInfo = sprintf('[%s|%d]',Error.name, Error.line);
        ExitStudy(sprintf('Problem displaying images/playing sounds\n%s',strcat(ErrorInfo,ME.message)));
        success = 0;
        return
    end % end try
end
Screen('Close',ISITexture);

