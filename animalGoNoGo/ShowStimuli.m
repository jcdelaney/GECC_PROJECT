% Given a block structure, display the animal sequence for that block

function [success num_fail] = ShowStimuli(TrialList)
success = 1;

% globals
global WINDOW % Window ID for Screen
global SUBJECT
global SESSION
global LOGID % file identifer of the log file
global NETSTATION
global CURRENT_RUN
global CURRENT_BLOCK
global NUM_TRIALS % keeps track of trial numbers
global DEBUG % 1 if using print lines instead of Screen calls, 0 otherwise
global RESP_DURATION % the duration (sec) of the response for each trial
global FEEDBACK_DURATION % the duration (sec) of the feedback for each trial
global ISI % the duration (sec) of the ISI
global EVENT
global ABORT
global BUTTON1
global LIGHT_GRAY
global RESOLUTION


if isempty(LOGID)
    LOGID = fopen([num2str(SUBJECT),'_',num2str(SESSION),'_ShowStimLog.txt'],'w');
end
ImageFolder = 'jpgs';
AudioFolder = 'wavs';
num_fail = 0;
rect = CenterRectOnPoint([0,0,800,450],RESOLUTION(1)/2,RESOLUTION(2)/2);

PositiveStimulus = [ImageFolder,filesep,'correct.jpg'];
NegativeStimulus = [ImageFolder,filesep,'incorrect.jpg'];
ISIImage         = [ImageFolder,filesep,'isi.jpg'];
TrialAudio       = [AudioFolder,filesep,'correct.wav'];
            
% inv: Trials 1..t have been shown and responses collected
for t=1:length(TrialList)
    if NETSTATION
        % resynchronize
        NetStation('Synchronize', 2.5);
    end
    % update number of trials
    NUM_TRIALS = NUM_TRIALS + 1;
    % ===
    % load the stimulus image
    % ===
    try
        TrialName = [ImageFolder,filesep,TrialList(t).stim,'.jpg'];
        % get trial type
        TrialType = TrialList(t).type;


        if DEBUG
            fprintf('TrialType is %s\n', TrialType);
            fprintf('Loading images... at %10.4f\n', cputime);
            ResponseVBLTime = cputime;
        else
            % load the textures
            StimPicture = imread(TrialName, 'jpg');
            StimTexture = Screen('MakeTexture', WINDOW, StimPicture);

            PosPicture = imread(PositiveStimulus, 'jpg');
            PosTexture = Screen('MakeTexture', WINDOW, PosPicture);
            
            NegPicture = imread(NegativeStimulus, 'jpg');
            NegTexture = Screen('MakeTexture', WINDOW, NegPicture);

            ISIPicture = imread(ISIImage, 'jpg');
            ISITexture = Screen('MakeTexture', WINDOW, ISIPicture);
            % load audio
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
        ExitStudy(sprintf('Problem creating/displaying images\n%s',strcat(ErrorInfo,ME.message)));
        success = 0;
        return
    end
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
            PsychPortAudio('Start', pahandle);
            PsychPortAudio('Stop',pahandle,1);
        end
        % send Trigger
        [Failed ErrorMessage] = SendTrigger(EVENT.ISI,ISIVBL);
        if Failed; ExitStudy(ErrorMessage); success=0; return; end;
        % write out info to log file
        fprintf(LOGID,'%d\t%d\t%10.4f\tISIOnset[%g]\t%d\n', CURRENT_RUN, CURRENT_BLOCK, ISIVBL, ISI, NUM_TRIALS);
    catch ME
        ExitStudy(ME.message);
        success=0;
        return
    end

    % ======
    % Trial
    % ======
    try
        % Response holds subject's response
        Response=0;
        
        if DEBUG
            fprintf('[ShowStimuli] Getting response...\n');
            pause(RESP_DURATION);
        else
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
                trialISI = randsample(ISI,1);
                [StimVBLTime] = Screen('Flip', WINDOW, ISIVBL + trialISI);

                fprintf('\t[%s trial]',TrialType);
        
                Failed=0;
                % send trigger
                switch TrialType
                    case 'Go'
                        [Failed ErrorMessage] = SendTrigger(EVENT.GoTrial,StimVBLTime);
                    case 'No Go'
                        [Failed ErrorMessage] = SendTrigger(EVENT.NoGoTrial,StimVBLTime);
                end
                if Failed
                    ExitStudy(ErrorMessage);
                    success=0;
                    return
                end
            end
            ResponseStart = StimVBLTime;
            HasResponded = 0;
            while (GetSecs - ResponseStart < RESP_DURATION) && ~HasResponded
            % listen for keyboard responses until RESP_DURATION
                [keyIsDown secs keyCode ] = KbCheck(-3);
                % check if key was pressed
                Response = 'No Go';
                if keyIsDown
                    if sum(keyCode(BUTTON1))
                        HasResponded = 1;
                        Response = 'Go';
                    elseif sum(keyCode(ABORT))
                        ExitStudy('Experiment aborted by user (in ShowStimuli)...');
                        success = 0;
                        return
                    end
                end % if keyIsDown
            end % while time < RESP_DURATION && ~HasResponded

            % if a response was made, send a trigger and load positive/negative stimulus
            Accurate = strcmp(Response,TrialType);
            if Accurate
                [Failed ErrorMessage] = SendTrigger(EVENT.Success,secs);
                fprintf('Subject correctly responded to a %s trial\n',TrialType);
                Screen('DrawTexture', WINDOW, PosTexture);
                Screen('DrawingFinished', WINDOW);
            else
                [Failed ErrorMessage] = SendTrigger(EVENT.Failure,secs);
                num_fail = num_fail + 1;
                fprintf('Subject incorrectly responded to a %s trial\n',TrialType);
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
            fprintf(LOGID,'%d\t%d\t%10.4f\tTrialResponse[%s]\t%d\t%d\n',CURRENT_RUN,CURRENT_BLOCK,ResponseVBLTime,Response,Accurate,NUM_TRIALS);
            Waitsecs(((ResponseStart + RESP_DURATION) - ResponseVBLTime) + FEEDBACK_DURATION);
            % close textures
            Screen('Close',StimTexture);
            Screen('Close',PosTexture);
            Screen('Close',NegTexture);
            % close audio stream
            PsychPortAudio('DeleteBuffer',buffer);
            PsychPortAudio('Close',pahandle);
        end % end if-else DEBUG
    catch ME
        Error = ME.stack(length(ME.stack)-1);
        ErrorInfo = sprintf('[%s|%d]',Error.name, Error.line);
        ExitStudy(sprintf('Problem creating/displaying images\n%s',strcat(ErrorInfo,ME.message)));
        success = 0;
        return
    end % end try

end
