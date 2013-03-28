% Return an array of runs, each consisting of blocks with cue, question and
% anchors.
function RUN = Runs
% declare globals
global ANCHOR_ORDER
global LOGID

% define possible sequences of go no go blocks
type1='GGN';
type2='GGGN';
type3='GGGGN';

% define the default sequence order for each run
RunDefault = {type1 type1 type1
			  type2 type2 type2
			  type3 type3 type3};

% randomize sequence order
RunA = RunDefault(randperm(9));
RunB = RunDefault(randperm(9));
RunC = RunDefault(randperm(9));
RunD = RunDefault(randperm(9));

% create default run order
RunOrderDefault = {RunA RunB RunC RunD};

% randomize run order
RunOrder = RunOrderDefault(randperm(4));

% preallocate size of Block and RUN for speed
Block = struct('cue','','anchors','');
Block(length(RunA)).cue='';
RUN = cell(1,2);

% logical to determine whether or not the anchors have been logged
% just do it once, but make sure there's a record
UnloggedGAnchors = 1;
UnloggedNAnchors = 1;

% inv: runs in RunOrder 1..r have been parsed and had Block structures created
%+based on their respective orders which are stored in RUN(r)
for r=1:length(RunOrder)
	BlockOrder = RunOrder{r};

	% inv: RUN 1..i have been translated and had Block values generated
	%+and stored in Block(i)
	for i=1:length(BlockOrder)
		btype=BlockOrder(i); % get the block type

		% create a new Block entry and add to the Block structure
        if strcmp(btype,'G') % Go block
			Block(i).cue='Go';
			Block(i).anchors={'Go', 'No Go'};
        elseif strcmp(btype,'N') % No Go block
			Block(i).cue='No Go';
			Block(i).anchors={'Go', 'No Go'};
		else
			error('Block type unknown!')
        end
%%      % adjust the anchor positions
%%      Block(i).anchors = Block(i).anchors(ANCHOR_ORDER);
        % if not already logged, put anchors in log file
        if UnloggedGAnchors && strcmp(btype,'G')
            fprintf(LOGID,'//GoAnchors: 1=%s\t2=%s\t',...
                Block(i).anchors{1}, Block(i).anchors{2});
            
            UnloggedGAnchors = 0;
        elseif UnloggedNAnchors && strcmp(btype,'N')
            fprintf(LOGID,'//NoGoAnchors: 1=%s\t2=%s\t',...
                Block(i).anchors{1}, Block(i).anchors{2});
            UnloggedNAnchors = 0;
        end
	end
	
	RUN{r} = Block;
end