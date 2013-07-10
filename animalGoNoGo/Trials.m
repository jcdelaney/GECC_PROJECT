% TRIALS - Generate trail strcuture for each run in the experiemt

function RUN = Trials(varargin)
% declare globals
global SUBJECT
global SESSION
global WORKING_DIRECTORY

% check for practice mode
if nargin > 0
    sprintf('RUNNING PRACTICE MODE!')
    NUM_RUNS = 1;
    NUM_BLOCKS_IN_RUN = 3;
else
    NUM_RUNS = 4;
    NUM_BLOCKS_IN_RUN = 9;
end

% read in the list of Good animals
fid = fopen('GList.csv','r');
line = fgetl(fid);
GArray=[];

while line ~= -1
    GArray{end+1} = line;
    line = fgetl(fid);
end
% create a separate randomized list for each run
GArray = repmat(GArray,1,int8(144/length(GArray)));
GAnimals{1} = GArray(randperm(length(GArray)));
GAnimals{2} = GArray(randperm(length(GArray)));
GAnimals{3} = GArray(randperm(length(GArray)));
GAnimals{4} = GArray(randperm(length(GArray)));
GIndex=0;
fclose(fid);

% read in the list of Bad animal(s)
fid = fopen('NList.csv','r');
line = fgetl(fid);
NArray=[];

while line ~= -1
    NArray{end+1} = line;
    line = fgetl(fid);
end
% create a separate randomized list for each run
NArray = repmat(NArray,1,int8(144/length(NArray)));
NAnimals{1} = NArray(randperm(length(NArray)));
NAnimals{2} = NArray(randperm(length(NArray)));
NAnimals{3} = NArray(randperm(length(NArray)));
NAnimals{4} = NArray(randperm(length(NArray)));
NIndex=0;
fclose(fid);

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
fprintf(Log,'Subject,Session,Run,Block,BlockType,Stimulus\n');
LogLine=cell(6,1); 
LogLine{1} = SUBJECT;
LogLine{2} = SESSION;
RUN = cell(1,NUM_RUNS);
% inv: runs in RUN 1..r have had trials created for each block, and the
% information has been written to a log file
for r=1:length(RUN)
	% store current run number in LogLine
	LogLine{3} = r;
		
	% define set of default block types
	DefaultBlockTypes = {'GGN' 'GGGN' 'GGGGN'};
	
	% set default block order for run
	DefaultRunOrder = repmat(DefaultBlockTypes,1,int8(NUM_BLOCKS_IN_RUN/length(DefaultBlockTypes)));
	
	% generate randomized block order for run
	RunOrder = DefaultRunOrder(randperm(length(DefaultRunOrder)));

	% create skeleton structure for run
	SKELETON = struct;
	
    % inv: trials TrialOrder 1..t have had animals added from the
    % appropriate array to NEWRUN{r}(b).trials(t).stimulus
    for b=1:length(RunOrder)    
        % store current block number in LogLine
        LogLine{4} = b;
        
        % define trial order for block
		TrialOrder = RunOrder{b};
        
        % inv: trials TrialOrder 1..t have had animals added from the
        % appropriate array to NEWRUN(b).trials(t).stimulus
        for t=1:length(TrialOrder)
            % add a trial from the appropriate array based on trial type
            type = TrialOrder(t);
            
            switch type
                case 'G' % add a Go trial for run r
                    GIndex = GIndex + 1;
                    SKELETON(b).trials(t).stim = ['g_',GAnimals{r}{GIndex}];
                    SKELETON(b).trials(t).type = 'Go';
                    
                case 'N' % add a No Go trial for run r
                    NIndex = NIndex + 1;
                    SKELETON(b).trials(t).stim = ['n_',NAnimals{r}{NIndex}];
                    SKELETON(b).trials(t).type = 'No Go';
            end
            % store stimulus in LogLine
            LogLine{6} = SKELETON(b).trials(t).stim;
            % update the log file
            fprintf(Log,'%d,%d,%d,%d,%s,%s\n',LogLine{:});
        end % trial TrialOrder
        
    end % BLOCK for
    
    % RUN 1 finished.  Reset G and N counters
    GIndex = 0;
    NIndex = 0;
	
	% save assembled structure in cell r in RUN
	RUN{r} = SKELETON;
    
end % RUN for

fclose(Log);
            
            