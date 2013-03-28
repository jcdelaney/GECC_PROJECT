% TRIALS - Generate trail strcuture for each run in the experiemt

function RUN = Trials(varargin)
% declare globals
global SUBJECT
global SESSION
global NUM_RUNS
global NUM_TRIALS
global WORKING_DIRECTORY

% read in the list of words
fid = fopen('wordList.csv','r');
line = fgetl(fid);
WordArray=[];

while line ~= -1
    WordArray{end+1} = line;
    line = fgetl(fid);
end

fclose(fid)

% prep log file
LogName = [WORKING_DIRECTORY,filesep,num2str(SUBJECT),'_',num2str(SESSION),'_TrialList.csv'];
LogNum=0;
% if a log of the same name exists, do not overwrite
while exist(LogName,'file')
    LogNum = LogNum + 1;
    LogName = [WORKING_DIRECTORY,filesep,num2str(SUBJECT),'_',num2str(SESSION),'_TrialList',num2str(LogNum),'.csv'];
end
fprintf('Creating trial list file %s...\n',LogName);
Log = fopen(LogName,'w');
fprintf(Log,'Subject,Session,Run,Trial,Visual Stimulus,Audio Stimulus,Trial Type\n');
LogLine=cell(7,1); 
LogLine{1} = SUBJECT;
LogLine{2} = SESSION;
RUN = cell(1,NUM_RUNS);
% inv: runs in RUN 1..r have had trials created for each block, and the
% information has been written to a log file

% ===
% Generate trial list
% ===
randWordArray1 = WordArray(randperm(length(WordArray)));
randWordArray2 = WordArray(randperm(length(WordArray)));
randWordArray = horzcat(randWordArray1,randWordArray2);
trialList = cell(1,NUM_TRIALS);

for i=1:length(trialList)
    % generate matched word list
    if i <= floor(NUM_TRIALS/2)
        trialList{i} = {randWordArray{i},randWordArray{i}};
    % generate mismatched word list
    else
        if i ~= ceil(NUM_TRIALS/2+1)
            trialList{i} = {randWordArray{i},randWordArray{i+1}};
        else
            trialList{i} = {randWordArray{i},randWordArray{length(WordArray)+1}};
        end
    end
end

trialListSuccess = 0;

while ~trialListSuccess
    trialList = trialList(randperm(length(trialList)));

    % confirm that no two words follow eachother in succession
    trialListSuccess = 1;
    for i=2:length(trialList)
        if strcmp(trialList{i-1}{1},trialList{i}{1}) || strcmp(trialList{i-1}{2},trialList{i}{2})
            trialListSuccess = 0;
        end
    end
end

% ===
% Generate Run Structure
% ===
trialIndex = 0;
for r=1:NUM_RUNS
	% store current run number in LogLine
	LogLine{3} = r;
    
    runLength = floor(length(trialList)/NUM_RUNS);

    if r == NUM_RUNS
        runLength = runLength + mod(length(trialList),NUM_RUNS);
	end

    trials = struct;
	
    % inv: trials TrialOrder 1..t have had words added from the
    % appropriate array to NEWRUN{r}.trials(t).stimulus
    for t=1:runLength    
        % store current trial number within run r in LogLine
        LogLine{4} = t;
        trialIndex = trialIndex + 1;

        type = strcmp(trialList{trialIndex}{1},trialList{trialIndex}{2});
        trials(t).visualStim = trialList{trialIndex}{1};
        trials(t).audioStim = trialList{trialIndex}{2};
        
        switch type
            case 0 % add a Match trial for run r
                trials(t).type = 'Mismatched Word';
                
            case 1 % add a Mismatched trial for run r
                trials(t).type = 'Matched Word';
        end
        % store stimulus in LogLine
        LogLine{5} = trials(t).visualStim;
        LogLine{6} = trials(t).audioStim;
        LogLine{7} = trials(t).type;
        % update the log file
        fprintf(Log,'%d,%d,%d,%d,%s,%s,%s\n',LogLine{:});
        
    end % trial for
    
	% save assembled structure in cell r in RUN
	RUN{r} = trials;
    
end % RUN for

fclose(Log);
            
            