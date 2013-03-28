function result = ppvt(subject, session, varargin)
% Usage:
%     >> ppvt(subject, session) % run the study
%     OR
%     >> ppvt(subject, session, optional) % run the study in practice mode or debug mode
%
% Parameters:
%     subject = the subject number (only numbers)
%
%     session = the session number (only numbers)
%
%     optional
%
%         0: Initiates practice mode. The study will loop through 10 trials 
%            until the user is able to accurately responsd to all 10 trials
%
%         1: Initiates debug mode where the program does not use Screen calls, 
%            and instead prints out information to the command window 
%
% Output:
%     result = ???
%
% Author: John Delaney, jcdelaney@uchicago.edu
% Adapted from code written by Keith Yoder, kjyoder@uchicago.edu
result = -1; % default, used for error checking
% ===
% DECLARE GLOBALS
% ===
VERSION = 1.0; % change this for major revisions

% these variables are used by other functions
global SUBJECT % Subject number
global SUBJECT_STRING % Subject number as a string, 0-padded to 3 digits
global SESSION % Session number
global LOGID % file identifier of log file
global NETSTATION % 1 if using NetStation, 0 otherwise
global BIOPAC % 1 if using BIOPAC, 0 otherwise
global PCPORT % parallel port ID
%10.4flobal CORRECTION
global DEBUG % 1 if in debug mode, 0 otherwise
global PRACTICE % 1 if in practice mode, 0 otherwise
global IFI % flip interval, used to get better timing
global WINDOW % window used for displaying stimuli
global WINDOW_RECT % dimensions of window
global WELCOME_TEXT % the text the user sees when they enter the scanner
global RESOLUTION % the intended resolution of the screen
global START_TIME % the time (secs) that the study started

global EVENT

% formatting globals
global COLOR % text foreground color
global BGCOLOR % screen background color
global TEXT_SIZE % the size of the font for text
global TEXT_FONT % the name of the font for test
global RESPONSE_BACKGROUND % color of response area background
global RESPONSE_EMPTY_COLOR % color for unselected box
global RESPONSE_CURRENT_COLOR % color of currently selected box
global RESPONSE_SUBMITTED_COLOR % color of box when response submitted
global BOXES % the number boxes in the Likert response
global BOX_WIDTH % the width (and height) of the response boxes (px)
global BOX_PADDING % the padding for the boxes (px)
global BOX_CENTERS % 2 x BOXES matrix of the top-left center of each box

global BUTTON1 % keyboard keys that correspond to the first button
global BUTTON2 % keyboard keys that correspond to the second button
global ADVANCE % keyboard keys that correspond to the advance button
global ABORT % keyboard keys that correspond to the abort button

% study data
global NUM_RUNS
global NUM_TRIALS % keeps track of trial numbers
global CURRENT_RUN % keeps track of current run
global CURRENT_BLOCK % keeps track of current block
global ANCHOR_ORDER % the rander permutation of 1, 2 and 3rd responses
global ANCHOR_VALUES % hold the nine anchors in the order they appear
global WORKING_DIRECTORY % directory of study and stimuli folder
global STIM_DURATION % the duration (sec) of the stimulus presentation for each trial
global FEEDBACK_DURATION % the duration (sec) of the feedback for each trial
global RESP_DURATION % the duration (sec) for a subject's response for each trial
global ISI % the duration (sec) of the ISI
global IMAGE_FOLDER % set directory for image folder
global AUDIO_FOLDER % set directory for image folder
global REST_DURATION % the duration (sec) of each rest block

% ===
% SET GLOBALS
% ===
RESOLUTION = [1024, 768];
TEXT_FONT = 'Arial';
TEXT_SIZE = 24;
WELCOME_TEXT = 'Welcome!\n\nPlease relax.  We will begin shortly.';
IMAGE_FOLDER = 'jpgs';
AUDIO_FOLDER = 'wavs';

% === TIMING VARIABLES ===
% change these values to modify study timing (all values in seconds)
STIM_DURATION =     1.5;% duration of the response for each trial
FEEDBACK_DURATION = 0.5;% duration of the response for each trial
ISI =               1.5;% duration of interval between trials
REST_DURATION =     1.5;% duration of each rest block
RESP_DURATION =     1.5;% duration of each rest block

% === LOGGING VARIABLES ===
% change these values to turn on NetStation or Biopac logging
NETSTATION = 0; % CHANGE THIS TO 1 IF RECORDING EEG
BIOPAC = 0; % CHANGE THIS TO 1 IF RECORDING FMRI
PCPORT = hex2dec('EC00');  % &H378 is standard parallel port
                        % but the CCSN sometimes uses the older &HEC00

% === COLOR VARIABLES ===
% change these value to modify the background/text/response bar colors
% define color (r, g, b) values
WHITE = [255 255 255];
BLUE = [0 0 255];
BLACK = [0 0 0];
GRAY = [72 72 72];
LIGHT_GRAY = [192 192 192];
% assign colors for global colors
COLOR = BLACK; % the color used for text
BGCOLOR = WHITE; % the background color of the screen
RESPONSE_BACKGROUND = BLACK; % background of response bar
RESPONSE_EMPTY_COLOR = WHITE; % color of empty response boxes
RESPONSE_CURRENT_COLOR = BLUE; % color of selected box
RESPONSE_SUBMITTED_COLOR = GRAY; % color of submitted box
% ===
% END GLOBAL VARIABLES
% ===

% let user know we're starting
fprintf('Starting at %10.4f...\n',cputime);

% ===
% RUNTIME VARIABLES
% these values are set at the start of each run
% ===
SUBJECT = subject;
SESSION = session;
NUM_RUNS = 10;
NUM_TRIALS = 160;
CURRENT_RUN=0;
CURRENT_BLOCK=0;
WORKING_DIRECTORY = pwd;
LOGID = [];
DEBUG = 0;

%==
%status=0;
%==
% check for optional parameters
if nargin > 2
    if varargin{1} == 0
        PRACTICE = 1;
        DEBUG = 0;
        NETSTATION = 0;
        %BIOPAC = 0;
        
    elseif nargin > 3 && varargin{1} == 0
        PRACTICE = 0;
        DEBUG = 1;
        NETSTATION = 0;
        %BIOPAC = 0;
    end
end

if PRACTICE
    WELCOME_TEXT = 'Welcome!\n\nPlease relax.  The Practice run will begin shortly.';
end

% randomly generate an anchor order
ANCHOR_ORDER = randperm(3);
ANCHOR_VALUES = {};



% === PREP SUBJECT DIRECTORY ===
% initialize TrialList for reloading previously stopped runs
TrialList = [];
% create a subdirectory for all files associated with this subject
% zero-bad number to be 3 characters long
SUBJECT_STRING = num2str(SUBJECT);
while length(SUBJECT_STRING) < 3
    SUBJECT_STRING = ['0', SUBJECT_STRING];
end
% create directory name
DirName = ['PPVT_',SUBJECT_STRING,'_',num2str(SESSION)];
% if default subdirectory name exists, warn user and give the option of
% loading previously-created trial data, or exiting
if exist([WORKING_DIRECTORY,filesep,DirName],'dir')
    resp = questdlg(sprintf('A directory already exists for this subject:\n%s',DirName),...
        'Subject directory already exists','Cancel','Restart a stopped run','Cancel');
    switch resp
        case 'Restart a stopped run'
            % check for a log file
            filename = strcat(WORKING_DIRECTORY,filesep,DirName,filesep,'Trials.mat');
            if exist(filename,'file')
                Variables = load(filename);
                TrialList = Variables.TrialList;
            else
                warndlg(sprintf('No trial list could be found for:\nSubject: %s  Session: %d',...
                    SUBJECT_STRING, SESSION), 'No Trials.mat file found!');
                ExitStudy();
                return
            end
        case 'Cancel'
            ExitStudy()
            return
    end
else
    % attempt to create the subdirectory
    [success message] = mkdir(WORKING_DIRECTORY, DirName);
    if ~ success || ~ exist([WORKING_DIRECTORY,filesep,DirName],'dir')
        ExitStudy();
        return
    end
    if ~isempty(message)
        ExitStudy(message);
        return
    end
end

% update working directory
WORKING_DIRECTORY = [ WORKING_DIRECTORY,filesep,DirName ];

% === PREP LOG FILE ===
% create default log name <Subject>_<Session>_log.csv
LogName = [WORKING_DIRECTORY,filesep,SUBJECT_STRING,'_',num2str(SESSION)];

% if TrialList is not empty, then this is a restarted run, so just reopen
% the log file for appending
if ~ isempty(TrialList)
    LOGID = fopen([LogName,'.log'], 'a');
end

% if default log name exists, warn user and exit
if isempty(LOGID) && exist([LogName,'.log'],'file')
    warndlg(sprintf('A log file already exists:\n%s',LogName),'Log already exists');
    ExitStudy();
    return
end
% attempt to open log
try
    if isempty(LOGID)
        LOGID = fopen([LogName,'.log'], 'w');
    end
    if LOGID == -1
        ExitStudy(sprintf('Problem opening %s',LogName));
        return
    else
        % write header to log file
        Date = datestr(now, 'HH:MM:SS AM dd-mmm-yyyy');
        fprintf(LOGID,'//Log file created (Version=%g) on %s for Subject=%s, Session=%s\n',VERSION,Date,SUBJECT_STRING,num2str(SESSION));
        fprintf('//Log file created %s for Subject=%s, Session=%s\n',Date,SUBJECT_STRING,num2str(SESSION));
    end
catch ME
    ExitStudy(ME.message);
    return
end

% ===
% END RUNTIME VARIABLES
% ===

% === TRIGGERING ===
EVENT=[];
fprintf('Sending initialize trigger...\n');

[Failed ErrorMessage] = SendTrigger('Initialize');
if Failed, ExitStudy(ErrorMessage); return; end;

% connect to NetStation
if NETSTATION
    if DEBUG
        fprintf('[NETSTATION] Connecting to 10.10.10.2\n');
    else
        [status, errorMessage] = NetStation('Connect', '10.10.10.2');
        if status % non-zero status means there was a problem
            fprintf('[NETSTATION] Error: %s\n', errorMessage);
            ExitStudy(errorMessage);
            return
        end
    end
end

% start NetStation
if NETSTATION
    if DEBUG
        fprintf('[NETSTATION] Synchronize and start recording.\n');
    else
        NetStation('Synchronize', 2.5);
        NetStation('StartRecording');
    end
end

% ===
% PREP STUDY
% ===

if DEBUG
    BUTTON1=-1;
    BUTTON2=-1;
    BUTTON3=-1;
    ADVANCE=-1;
    ABORT=-1;
end

% initialize StartRun
StartRun = [];

% initialize StartBlock
StartBlock = [];

% if a TrialList doesn't already exist, create one
if isempty(TrialList)
    % Create trial list
    fprintf('Generating trial list...\n');
    if PRACTICE
        % creates array of 1 run and generates a trial list for that run
        TrialList = Trials(PRACTICE);
    else
        % creates array of 4 runs and generates a trial list for each run
        TrialList = Trials();
    end
else
    % ask for starting run number and starting block number
    resp = inputdlg({'Which existing run would you like to start with?',...
                     'Which existing block would you like to start with?'},...
                     'Restart a Stopped Run');
    StartRun = str2double(resp{1});
    StartBlock = str2double(resp{2});
    if ~ismember(StartRun,(1:3))
        fprintf('Invalid RunBlock number\n');
        ExitStudy();
    end
    if ~ismember(StartBlock,(1:9))
        fprintf('Invalid StartBlock number\n');
        ExitStudy();
    end
end

% stop putting key presses in command window
ListenChar(2);

try
    % export trials
    save(strcat(WORKING_DIRECTORY,filesep,'Trials.mat'),'TrialList');
catch ME
    ExitStudy(sprintf('Problem saving Trials structure:%s',ME.message));
    return
end


result = TrialList;
% add timestamp to log
if DEBUG
    fprintf(LOGID,'//TrialList generated at %s\n', cputime);
else
    fprintf(LOGID,'//TrialList generated at %10.4f\n', GetSecs());
end

% ===
% PTB SETUP
% ===

% Check proper PTB installation
if DEBUG
    fprintf('[PPVT] This is where I would get Screen information\n');
    fprintf('[PPVT] Getting flip interval\n');
    START_TIME = cputime;
    WINDOW_RECT = [-1 -1 -1 -1];
else
    try % try a bunch to get MEX files to compile before hand
        % hide the cursor
        HideCursor;
        ScreenID = max(Screen('Screens'));
        oldlevel = PsychPortAudio('Verbosity',0);
        oldLevel = Screen('Preference', 'Verbosity', 1);
        Priority(1); % make the study high-priority (but not real-time)
        % modify the screen resolution
        OldResolution = Screen('Resolution', ScreenID, RESOLUTION(1), RESOLUTION(2));
        % open a window
        [ WINDOW WINDOW_RECT ] = Screen('OpenWindow', ScreenID, BGCOLOR, [], [], 2);
        % get the current time in high-precision seconds
        START_TIME = GetSecs();
        % get the flip interval
        [ IFI ] = Screen('GetFlipInterval', WINDOW, 100, 0.00005, 20);
        % wait one IFI
        WaitSecs(IFI);
        % For cross-platform compatibility, use standard key names
        KbName('UnifyKeyNames');
        % define key mappings
        BUTTON1=KbName({'LeftArrow','7','7&'});
        BUTTON2=KbName({'DownArrow','8','8*'});
        ADVANCE=KbName({'q'});
        ABORT=KbName({'ESCAPE'});
        % simulate KbInput
        [null, null, keyCode] = KbCheck(-3);
        % set default font size and font name
        Screen('TextSize', WINDOW, TEXT_SIZE);
        Screen('TextFont', WINDOW, TEXT_FONT);
        % draw a period at the center of the screen with the BGCOLOR
        DrawFormattedText(WINDOW, '.', 'center', 'center', BGCOLOR);
        % Flip the window
        [ pvbl ] = Screen('Flip', WINDOW);
        InitializePsychSound;
        % TODO: add timing, ala WaitTil()
    catch ME
        ExitStudy(sprintf('Problem launching screen.\n%s',ME.message));
        return
    end
end

% add screen information to log file
fprintf(LOGID,'//Screen dimensions are %dx%d\n',WINDOW_RECT(3:4));

% ===
% RUN EXPERIMENT
% ===
Third = round(WINDOW_RECT(4)/3); % used for putting '.' at bottom

% Set the trigger to "off" (nothing currently happening)
[Failed, ErrorMessage] = SendTrigger(EVENT.ExperimentStart);
if Failed,
    ExitStudy(ErrorMessage);
    return
end;

% ===
% WELCOME SCREEN
% ===
% show the welcome screen
if DEBUG
    fprintf('%s\n',sprintf('[PPVT] Showing welcome screen:\n+--\n%s\n+--\n',WELCOME_TEXT));
else
    try
        [null, ny] = DrawFormattedText(WINDOW, WELCOME_TEXT,...
            'center', 'center', COLOR);

        % add '.' to bottom
        [nx2 ny2] = DrawFormattedText(WINDOW, '.', 'center', ny + Third,...
            [0 0 0]);
        % tell PTB drawing is finished
        Screen('DrawingFinished', WINDOW,0);
        % flip the window
        [qvbltime , null, null, missed ]=Screen('Flip',WINDOW, pvbl + IFI);
        if missed>0
            fprintf('Deadline missed: Welcome screen\n');
        end
        % get user response
        ValidKeys={'q'};

        fprintf(':: Welcome screen :: Press ''q'' to continue\n');
        
        KeepChecking = 1;
        while KeepChecking
            WaitSecs(.05);
            [keyIsDown secs keyCode ] = KbCheck(-3);
            % check if key was pressed
            if keyIsDown
                keyPressed = KbName(find(keyCode));
                % ignore key press if not in ValidKeys
                if ismember(keyPressed, ValidKeys)
                    switch keyPressed
                        case 'q'
                            KeepChecking = 0;
                            KeyPressTime = secs - qvbltime;
                    end
                end % end if ismember(keyPressed, ValidKeys)
            end
        end

    catch ME
        ExitStudy(ME.message);
        return
    end
end

RunStartOffset = GetSecs;

% if not set, set StartRun to 1
if isempty(StartRun)
    StartRun = 1;
end

% if not set, set StartBlock to 1
if isempty(StartBlock)
    StartBlock = 1;
end

CURRENT_RUN = StartRun - 1;
try
    % inv: for each block in each run in everyday_actions, display stimuli and
    % record response has been done
    for run=StartRun:length(TrialList)
        CURRENT_RUN = CURRENT_RUN + 1;

        RUN = TrialList{run};

        % ===
        % Show 'please wait' screen
        % ===
        try
            String = 'Please wait...';
            if DEBUG
                fprintf('[PPVT] Showing wait screen...(waiting for user ''q'')...\n');
                fprintf('+---\n%s\n+---\n',String);
                %pause(.5);
                secs = cputime;
                fprintf('[PPVT] simulating ''q'' press...\n');
            else
                fprintf(':: showing ''Please wait'' screen :: press ''q'' to proceed\n');
                
                [null, ny ] = DrawFormattedText(WINDOW, String,...
                    'center', 'center', COLOR);
                % add '.' to bottom
                DrawFormattedText(WINDOW, '.', 'center', ny + Third,...
                    [0 0 0]);
                % tell PTB drawing is finished
                Screen('DrawingFinished', WINDOW);
                % flip the window
                [null , null , null, missed ]=Screen('Flip',WINDOW, RunStartOffset + IFI);
                if missed>0
                    fprintf('Deadline missed: ''q'' press\n');
                end
                % wait for ADVANCE
                [null, secs keyCode] = KbCheck(-3);

                while ~(sum(keyCode(ADVANCE)) || sum(keyCode(ABORT)))
                    WaitSecs(.05);
                    [null, secs keyCode ] = KbCheck(-3);
                end
                if sum(keyCode(ABORT))
                    ExitStudy('Study aborted by users...');
                    return
                end
            end % end if-else DEBUG
        catch ME
            ExitStudy(ME.message);
            return
        end

        % ===
        % wait for scanner 's' input
        % ===
        try
            if DEBUG
                fprintf('[PPVT] Waiting for scanner input (''s'')...\n');
                fprintf('+---\n%s\n+---\n',String);
                %pause(.5);
                secs = cputime;
                fprintf('[PPVT] simulating ''s'' press...\n');
            else
                fprintf(':: waiting for ''scanner'' input :: press ''s'' to proceed\n');
                %fprintf('Waiting for scanner input...\n');
                % draw without '.'
                DrawFormattedText(WINDOW, String, 'center', 'center',COLOR);
                Screen('DrawingFinished', WINDOW);

                Screen('Flip',WINDOW,secs + IFI);
                % get scanner input
                % wait for scanner
                [null, secs, keyCode] = KbCheck(-3);
                SCANNER=KbName('s');

                while ~(sum(keyCode(SCANNER)) || sum(keyCode(ABORT)));
                    WaitSecs(.05);
                    [null, secs, keyCode ] = KbCheck(-3);
                end
                if sum(keyCode(ABORT))
                    ExitStudy('Study aborted by users...');
                    return
                end
            end % end if-else DEBUG
            [Failed, ErrorMessage] = SendTrigger(EVENT.ScannerStart, secs);
            if Failed, ExitStudy(ErrorMessage); return; end;
        catch ME
            ExitStudy(ME.message);
            return
        end

        % show stimuli
        [success, num_fail] = ShowStimuli(RUN);
        if ~ success
            ExitStudy('Problem occurred in ShowStimuli.m');
            return
        end

        % rest
        if DEBUG
            fprintf('=== Block %d === Rest ===\n', CURRENT_BLOCK);
            RestVBL = cputime;
            %pause(REST_DURATION);
        else
            [null, ny ] = DrawFormattedText(WINDOW, 'AWARENESS CHECK','center', 'center', COLOR);
            % tell PTB drawing is finished
            Screen('DrawingFinished', WINDOW);
            % flip the window
            RestVBL = Screen('Flip',WINDOW);
            WaitSecs(5);
        end
        % ===
        % AWARENESS CHECK
        % ===
        if DEBUG
            fprintf('Presenting random trial to test for accuracy');
        else
            fprintf('[Awareness Check]\n');
            rand_run = randi(NUM_RUNS);
            AWARENESS_RUN = TrialList{rand_run};
            rand_trial = randi(floor(NUM_TRIALS/NUM_RUNS));

            AwareVBL = GetSecs;
            [Failed, ErrorMessage] = SendTrigger(EVENT.AwarenessCheck, AwareVBL);
            if Failed, ExitStudy(ErrorMessage); return; end;

            [success, num_fail] = ShowStimuli(AWARENESS_RUN(rand_trial),1);

            if ~ success
                ExitStudy('Problem occurred in ShowStimuli.m');
                return
            end
        end    
        % ===
        % RUN COMPLETION SCREEN
        % ===
        % show the welcome screen
        if DEBUG
            fprintf('%s\n',sprintf('[PPVT] Showing welcome screen:\n+--\n%s\n+--\n',WELCOME_TEXT));
        
        else
            try
                % show run completion text
                DoneText = 'You have finished a run.\n\nRelax, but please do not move.';
                [null, ny ] = DrawFormattedText(WINDOW, DoneText,...
                    'center', 'center', COLOR);
                % add '.' to bottom
                DrawFormattedText(WINDOW, '.', 'center', ny + Third,...
                    COLOR);
                % tell PTB drawing is finished
                Screen('DrawingFinished', WINDOW,0);
                % flip the window
                [null , null , null, missed ]=Screen('Flip',WINDOW, RestVBL + ISI);
                disp(PRACTICE)
                if missed>0
                    fprintf('Deadline missed: Welcome screen\n');
                end
                fprintf(':: Run number %d finished\n:: CHECK IMPEDANCES, then ''q'' to continue (to abort, press ESC)\n',run);
                
                [null, null, keyCode ] = KbCheck(-3);
                % wait for ADVANCE or ABORT
                while ~(sum(keyCode(ADVANCE)) || sum(keyCode(ABORT)));
                    WaitSecs(.05);
                    [null, secs, keyCode ] = KbCheck(-3);
                end
                % determine whether was advance or abort
                if sum(keyCode(ABORT))
                    ExitStudy(sprintf('Study aborted by user after run %d',CURRENT_RUN));
                    return
                end
                % ASSERT: if not ABORT, was ADVANCE, so go on
            catch ME
                ExitStudy(ME.message);
                return
            end
        end % end Completed a Run screen
        WaitSecs(0.5);
        RunStartOffset = GetSecs;
    end
catch ME
    Error = ME.stack(length(ME.stack));
    ErrorInfo = sprintf('[%s|%d]',Error.name, Error.line);
    ExitStudy(sprintf('While running study: %s\n',strcat(ErrorInfo,ME.message)));
    return
end
PsychPortAudio('Verbosity',oldlevel);
Screen('Preference', 'Verbosity', oldlevel);
% return the screen resolution
%Screen('Resolution', ScreenID, OldResolution);
time = fix(clock);
ExitStudy(sprintf('Finished successfully at %s\n',sprintf('%d:%d:%2d',time([4 5 6]))));
