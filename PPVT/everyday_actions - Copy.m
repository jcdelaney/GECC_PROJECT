% EVERYDAY_ACTIONS() - This is the stimulus presentation for the
%     "Evaluation of Everyday Actions" study.
%
%       The study involves viewing short animations (3 flashed stills) and
%       then making ratings based on the condition, either:
%           Location: was it definitely outside, inside, or undetermined?
%           Motive: was the actors motive good, bad, or neither?
%           Outcome: was the outcome of the action good, bad, or neither?
%
%       At the start, the three CSV files, GoodList, BadList and NeutList
%       are loaded and used to generate a unique trial order for each
%       run.  Each run consists of 15 pseudo random blocks, 5 for each
%       condition.
%
%       To make changes to the timing information, modify the values in the
%       GLOBAL TIMING VARIABLES section
%
% Usage:
%     >> everyday_actions(subject, session) % run the study
%     OR
%     >> everyday_actions(subject, session, debug) % simulate a run
%                                                    % without using PTB
%                                                    % (just text output)
%
% Parameters:
%     subject        = the subject number (only numbers)
%
%     session        = the session number (only numbers)
%
%     (Optional)
%     debug        = (default is empty), 1 if testing
%               testing does not use Screen calls, and instead prints out
%               information to the command window
%
% Output:
%     result = ???
%
% Author: Keith Yoder, kjyoder@uchicago.edu
function result = everyday_actions(subject, session, varargin)
result = -1; % default, used for error checking
% ===
% DECLARE GLOBALS
% ===
VERSION = 2.2; % change this for major revisions
% Change log:
%   V 2.2 (EEG)
%   2012/05/25 - kjyoder    1. changed timing (shorter)
%                           2. updated ExitStudy to stop/close NetStation
%                               and send 0 to BioPac
%                           3. updated parallel port address for CCSN
%                           4. added WaitSecs(0.5) to first 'q' wait
%
%   V 2.1 (EEG)
%   2012/05/24 - kjyoder    1. always print out info to command window
%                               (prompts/progress for dual-monitor setup)
%                           2. EEAEvents renumbered to values 0-15
%                           3. 6 second REST_DURATION
%                           4. synchronize with netstation every trial
%
%   V 1.4
%   2012/05/23 - kjyoder    1. added WASHOUT_JITTER to add slight jitter
%                           2. added WASHOUT_JITTER implementation to
%                               ShowStimuli.m
%                           3. moved RestBlockStart trigger into DEBUG
%                               block (now trigger sent at right time)
%
%   V 1.3
%   2012/05/02 - kjyoder    1. added WaitSecs(0.5) after Run End before
%                               Safety (no more "double 'q' taps"
%                           2. changed CURRENT_RUN start so it starts with
%                               1 instead of 2 (set by StartRun)
%                           3. changed logging for ISI from %d to %g
%                               (no more 1.20000e+000)
%
%   V 1.2
%   2012/05/01 - kjyoder    1. timing based on VBL rather than OnsetTime
%                           2. added skip ('s') for training
%                           3. added repeat ('r') screen for training
%                           4. added Trials.mat saving
%                           5. added ability to restart stopped run
%                           6. removed "append a number" options
%
%   V 1.1
%   2012/04/29 - kjyoder    1. RESP_DURATION now length of response slide
%                           (no longer reset by subject response)
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
global BUTTON3 % keyboard keys that correspond to the third button
global ADVANCE % keyboard keys that correspond to the advance button
global ABORT % keyboard keys that correspond to the abort button

%10.4flobal VALID_KEYS % allowed keys for responding to study questions
% 4 x BOXES matrix of left, top, right, and bottom edges of response area boxes
global BOXES_RECT
% 3 x BOXES matrix of r, g, b values for background and box in response
% area
global BOXES_COLOR
% study data
global NUM_TRIALS % keeps track of trial numbers
global CURRENT_RUN % keeps track of current run
global CURRENT_BLOCK % keeps track of current block
global ANCHOR_ORDER % the rander permutation of 1, 2 and 3rd responses
global ANCHOR_VALUES % hold the nine anchors in the order they appear
global WORKING_DIRECTORY % directory of study and stimuli folder
global CUE_DURATION % the duration (sec) of the cue for each block
global PIC1_DURATION % the duration (sec) of the first image in each trial
global PIC2_DURATION % the duration (sec) of the second image in each trial
global PIC3_DURATION % the duration (sec) of the third image in each trial
global WASHOUT_DURATION % the duration (sec) of the "washout" slide
global WASHOUT_JITTER % the duration (sec) to add/subtract from WASHOUT_DUR
global RESP_DURATION % the duration (sec) of the response for each trial
global FEEDBACK_DURATION % the duration (sec) of the response for each trial
global ISI % the duration (sec) of the ISI
global IMAGE_FOLDER % set directory for image folder
global REST_DURATION % the duration (sec) of each rest block

% ===
% SET GLOBALS
% ===
RESOLUTION = [1024, 768];
TEXT_FONT = 'Arial';
TEXT_SIZE = 24;
WELCOME_TEXT = 'Welcome!\n\nPlease relax.  We will begin shortly.';
IMAGE_FOLDER = 'jpgs';

% === TIMING VARIABLES ===
% change these values to modify study timing (all values in seconds)
CUE_DURATION =      1;  %3; % duration of the cue for each block
PIC1_DURATION =     1;  %1; % duration of the first image in each trial
PIC2_DURATION =     0.2;%.2; % duration of the second image in each trial
PIC3_DURATION =     1;  %1; % duration of the third image in each trial
WASHOUT_DURATION =  0.5;  %1;
WASHOUT_JITTER =    [-.045,-.035,-.017,.017,.035,.045];
RESP_DURATION =     1.5;  %3; % duration of the response for each trial
FEEDBACK_DURATION = 0.5;  %3; % duration of the response for each trial
ISI =               1.5;  %1;
REST_DURATION =     1.5; %14; % duration of each rest block

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
BGCOLOR = LIGHT_GRAY; % the background color of the screen
RESPONSE_BACKGROUND = BLACK; % background of response bar
RESPONSE_EMPTY_COLOR = WHITE; % color of empty response boxes
RESPONSE_CURRENT_COLOR = BLUE; % color of selected box
RESPONSE_SUBMITTED_COLOR = GRAY; % color of submitted box
% === RESPONSE VARIABLES ===
% change these value to modify the appearance of the response area
BOX_WIDTH = 80;
BOX_PADDING = 10;
BOX_CENTERS = [340 512 684; 520 520 520];
BOXES = 3;
BOXES_RECT = [];
BOXES_COLOR = [];
DefineResponseArea(); % update BOXES_RECT and BOXES_COLOR for response area
fprintf('Response Area defined.\n');
%disp(BOXES_RECT)

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
NUM_TRIALS=0;
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
    if varargin{1} == 1
        PRACTICE = 1;
        DEBUG = 0;
        NETSTATION = 0;
        %BIOPAC = 0;
        
    elseif nargin > 3 && varargin{2} == 1
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
DirName = ['EEA_',SUBJECT_STRING,'_',num2str(SESSION)];
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
    fprintf('[EEA] This is where I would get Screen information\n');
    fprintf('[EEA] Getting flip interval\n');
    START_TIME = cputime;
    WINDOW_RECT = [-1 -1 -1 -1];
else
    try % try a bunch to get MEX files to compile before hand
        % hide the cursor
        HideCursor;
        ScreenID = max(Screen('Screens'));
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
        % TODO: add timing, ala WaitTil()
    catch ME
        ExitStudy(sprintf('Problem launching screen.\n%s',ME.message));
        return
    end
end

% add screen information to log file
fprintf(LOGID,'//Screen dimensions are %dx%d\n',WINDOW_RECT(3:4));
% report start time
fprintf(LOGID,'%d\t%d\t%10.4f\tSTART_TIME\t1\n',CURRENT_RUN,CURRENT_BLOCK,START_TIME);

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
    fprintf('%s\n',sprintf('[EEA] Showing welcome screen:\n+--\n%s\n+--\n',WELCOME_TEXT));
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

% ===
% TRAINING SLIDES
% ===
%try
%    RepeatPractice=1;
%
%    while RepeatPractice
%        FlushEvents('keyDown');
%        fprintf(':: launching PracticeSlide :: press ''q'' to proceed or ''s'' to skip\n');
%        [Failed FinishedAt] = PracticeSlide;
%        if Failed
%            ExitStudy('Closed because of PracticeSlide');
%            return
%        end
%        % clear buffer
%        FinishedAt = Screen('Flip', WINDOW, FinishedAt + IFI);
%        [nx ny] = DrawFormattedText(WINDOW, 'To repeat training, press R key', 'center','center',[0 0 0]);
%        fprintf(':: training finished :: press ''r'' to repeat or ''q'' to proceed');
%        DrawFormattedText(WINDOW, '.', 'center', ny + Third,[0 0 0]);
%        % tell PTB drawing is finished
%        Screen('DrawingFinished', WINDOW,0);
%        % flip the window
%        [FinishedAt , null, null, missed ]=Screen('Flip',WINDOW, FinishedAt + IFI);
%
%        [null, null, keyCode] = KbCheck(-3);
%
%        while ~(sum(keyCode(ADVANCE)) || sum(keyCode(ABORT)) || sum(keyCode(KbName('r'))));
%            WaitSecs(.05);
%            [null, null, keyCode ] = KbCheck(-3);
%        end
%        if sum(keyCode(ABORT))
%            ExitStudy('Study aborted by users...');
%            return
%        end
%        if sum(keyCode(ADVANCE))
%            RepeatPractice=0;
%        end
%    end
%catch ME
%    ExitStudy(ME.message);
%    return
%end

% CHANGE THIS WHEN PUTTING PRACTICE BACK IN
RunStartOffset = GetSecs;
% wait so q doesn't carry over
WaitSecs(0.5);

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
    inprogress = 1;
    while inprogress
        for run=StartRun:length(TrialList)
            CURRENT_RUN = CURRENT_RUN + 1;
    
            RUN = TrialList{run};
    
            % ===
            % Show 'please wait' screen
            % ===
            try
                String = 'Please wait...';
                if DEBUG
                    fprintf('[EEA] Showing wait screen...(waiting for user ''q'')...\n');
                    fprintf('+---\n%s\n+---\n',String);
                    %pause(.5);
                    secs = cputime;
                    fprintf('[EEA] simulating ''q'' press...\n');
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
                % send trigger
                [Failed ErrorMessage] = SendTrigger(EVENT.QPress, secs);
                if Failed, ExitStudy(ErrorMessage); return; end;
            catch ME
                ExitStudy(ME.message);
                return
            end
    
            % ===
            % wait for scanner 's' input
            % ===
            try
                if DEBUG
                    fprintf('[EEA] Waiting for scanner input (''s'')...\n');
                    fprintf('+---\n%s\n+---\n',String);
                    %pause(.5);
                    secs = cputime;
                    fprintf('[EEA] simulating ''s'' press...\n');
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
                    % write to log
                    fprintf(LOGID,'%d\t%d\t%10.4f\tScannerStart\t1\n',CURRENT_RUN,CURRENT_BLOCK,secs);
                end % end if-else DEBUG
                [Failed, ErrorMessage] = SendTrigger(EVENT.ScannerStart, secs);
                if Failed, ExitStudy(ErrorMessage); return; end;
            catch ME
                ExitStudy(ME.message);
                return
            end
    
            % ===
            % run the block
            % ===
            CURRENT_BLOCK = StartBlock - 1;
            % inv: each block in RUN has had stimuli displayed and responses recorded
            for block=StartBlock:length(RUN)
                BLOCK=RUN(block);
                CURRENT_BLOCK=CURRENT_BLOCK+1;
                % show cue
                if DEBUG
                    %fprintf('=== Block %d === %s === [%s]\n',CURRENT_BLOCK,BLOCK.cue,cputime);
                    BlockOnset = cputime;
                else
                    BlockOnset = GetSecs();
                end
                % send trigger for block start
                [Failed, ErrorMessage] = SendTrigger(EVENT.BlockStart,BlockOnset);
                if Failed, ExitStudy(ErrorMessage); return; end;
    
                % write block start to log
                fprintf(LOGID,'%d\t%d\t%10.4f\tBlockStart\t%d\n',CURRENT_RUN,CURRENT_BLOCK,BlockOnset,CURRENT_BLOCK);
    
                fprintf('Now running block %d\n[BLOCK %d]\n...to interrupt, hold ESC key\n',block,block);
                % show stimuli
                [success, num_fail] = ShowStimuli(BLOCK.trials);
                if ~ success
                    ExitStudy('Problem occurred in ShowStimuli.m');
                    return
                end
    
                % rest
                if DEBUG
                    fprintf('=== Block %d === Rest ===\n', CURRENT_BLOCK);
                    RestVBL = cputime;
                    %pause(REST_DURATION);
                    [Failed, ErrorMessage] = SendTrigger(EVENT.RestBlockStart, RestVBL);
                    if Failed, ExitStudy(ErrorMessage); return; end;
                else
                    ISIImage = [IMAGE_FOLDER,filesep,'isi.jpg'];
                    ISIPicture = imread(ISIImage, 'jpg');
                    ISITexture = Screen('MakeTexture', WINDOW, ISIPicture);
                    Screen('DrawTexture', WINDOW, ISITexture);
                    % tell PTB drawing is finished
                    Screen('DrawingFinished', WINDOW);
                    % flip the window
                    RestVBL = Screen('Flip',WINDOW);
                    % wait for REST_DURATION, but listen for ABORT input
                    [Failed, ErrorMessage] = SendTrigger(EVENT.RestBlockStart, RestVBL);
                    fprintf('[Rest]\n');
                    if Failed, ExitStudy(ErrorMessage); return; end;
                end
                
    
                % write to log
                fprintf(LOGID,'%d\t%d\t%10.4f\tRestBlock\t%d\n',CURRENT_RUN,CURRENT_BLOCK,RestVBL,CURRENT_BLOCK);
            end % for block
            % reset starting block
            StartBlock = 1;
            % ===
            % RUN COMPLETION SCREEN
            % ===
            % show the welcome screen
            if DEBUG
                fprintf('%s\n',sprintf('[EEA] Showing welcome screen:\n+--\n%s\n+--\n',WELCOME_TEXT));
            
            else
                try
                    % show run completion text
                   practice_success = (num_fail == 0);
                   if PRACTICE & practice_success
                       DoneText = ['Practice run complete.\n\nYour score was ',num2str(10-num_fail),' out of 10.\n\nPlease try again.'];
                   elseif PRACTICE
                       DoneText = ['Practice run complete.\n\nYour score was ',num2str(10-num_fail),' out of 10.\n\nGood job!'];
                   else
                       DoneText = 'You have finished a run.\n\nRelax, but please do not move.';
                   end
                    [null, ny ] = DrawFormattedText(WINDOW, DoneText,...
                        'center', 'center', COLOR);
                    % add '.' to bottom
                    DrawFormattedText(WINDOW, '.', 'center', ny + Third,...
                        COLOR);
                    % tell PTB drawing is finished
                    Screen('DrawingFinished', WINDOW,0);
                    % flip the window
                    [null , null , null, missed ]=Screen('Flip',WINDOW, GetSecs + 5);
                    if PRACTICE & practice_success 
                        WaitSecs(5);
                    end
                    if ~PRACTICE
                        if missed>0
                            fprintf('Deadline missed: Welcome screen\n');
                        end
        
                        fprintf(':: Run number %d finished\n:: CHECK IMPEDANCES, then ''q'' to continue (to abort, press ESC)\n',run);
                        
                        [null, null, keyCode ] = KbCheck(-3);
                        % wait for ADVANCE or ABORT
                        while ~(sum(keyCode(ADVANCE)) || sum(keyCode(ABORT)))
                            WaitSecs(0.05);
                            [null, null, keyCode] = KbCheck(-3);
                        end
                        % determine whether was advance or abort
                        if sum(keyCode(ABORT))
                            ExitStudy(sprintf('Study aborted by user after run %d',CURRENT_RUN));
                            return
                        end
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
        if PRACTICE
            TrialList = Trials(PRACTICE);
            if practice_success
                inprogress = 0;
            end
        else
            inprogress = 0;
        end
    end
catch ME
    ExitStudy(sprintf('While running study: %s\n',ME.message));
    return
end
% return the screen resolution
%Screen('Resolution', ScreenID, OldResolution);
time = fix(clock);
ExitStudy(sprintf('Finished successfully at %s\n',sprintf('%d:%d:%2d',time([4 5 6]))));
