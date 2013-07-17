% Sends a trigger to either BioPac or NetStation
function [Failed ErrorMessage] = SendTrigger(varargin)
% define globals
global CURRENT_RUN
global CURRENT_BLOCK
global NETSTATION
global BIOPAC
global PCPORT
global SUBJECT_STRING
global WORKING_DIRECTORY
global EVENT
global LOGID
global DEBUG

% set initial values for Failed and ErrorMessage
Failed = 0;
ErrorMessage = '';

%if DEBUG, fprintf('//[SendTrigger] called\n'); end;

% if varargin is 'initiate', write out EEAEvents mapping
if nargin > 0
    arg = varargin{1};
    if ischar(arg) % command
        if strcmp(arg,'Initialize') % write out EEAEvents lexicon store EEAEvents
            try
                LexPath = strcat(WORKING_DIRECTORY, filesep, SUBJECT_STRING,'_lex.log');
                fprintf('Creating lexicon %s...\n',LexPath);
                LexID = fopen(LexPath,'w');
                EVENT = evalin('base','EEAEvents');
                Properties = properties(EVENT);
                
                %assignin('base','props',Properties);
                % write out all Properties
                for i=1:length(Properties)
                    %fprintf('%d Properties\n',length(Properties));
                    prop = Properties{i};
                    %fprintf('%s\n',prop);
                    if length(EVENT.(prop)) == 1
                        fprintf(LexID,'%s=%d\n',prop,EEAEvents.(prop));
                    else
                        fprintf(LexID,'%s=%d,%s\n',...
                            prop,...
                            EVENT.(prop){1},...
                            EVENT.(prop){2});
                    end
                end
                fclose(LexID);
            catch ME
                Failed = 1;
                Function = ME.stack(length(ME.stack)).name;
                Line = ME.stack(length(ME.stack)).line;
                ErrorMessage = sprintf('[%s|%d] %s',Function,Line,ME.message);
                return
            end
            % set default anchor values
            fprintf(LOGID,'//[SendTrigger] Initialization\n');
        end
    elseif iscell(arg) % EEAEvents to send
        % send to biopac
        if BIOPAC
            %fprintf('%%%\n%%%\nBIOPAC\n%%%\n%%%\n');
            try
                if DEBUG
                    fprintf(LOGID,'//[SendTrigger] %10.4f\t%d\n', cputime, arg{1});
                else
                    lptwrite(PCPORT, arg{1});
                    fprintf(LOGID,'%d\t%d\t%10.4f\tSendTrigger\t%d\n',CURRENT_RUN,CURRENT_BLOCK,GetSecs,arg{1});
                end
            catch ME
                Failed = 1;
                Function = ME.stack(length(ME.stack)).name;
                Line = ME.stack(length(ME.stack)).line;
                ErrorMessage = sprintf('[%s|%d|LPTWRITE %s',...
                    Function, Line, ME.message);
                return
            end
        end
        
        % if netstation, look for onset
        % 	NetStation('Event' [,code] [,starttime] [,duration] [,keycode1] [,keyvalue1] [...])
%
%           Send an event to the NetStation host.
%
% 			"code"		The 4-char event code (e.g., 'STIM')
% 						Default: 'EVEN'
% 			"starttime"	The time IN SECONDS when the event started. The VBL time
% 						returned by Screen('Flip') can be passed here as a parameter.
% 						Default: current time.
% 			"duration"	The duration of the event IN SECONDS.
% 						Default: 0.001.
% 			"keycode"	The 4-char code of a key (e.g., 'tria').
% 			"keyvalue"	The integer value of the key (>=-32767 <=32767)
% 			The keycode-keyvalue pairs can be repeated arbitrary times.
        if NETSTATION
            fprintf(LOGID,'//[NetStation] %10.4f\t%d\n', cputime, arg{1});
            % if a duration exists, use it
            if nargin > 1
                Duration = varargin{2};
            else
                % otherwise, use current time
                if DEBUG
                    Duration = cputime;
                else
                    Duration = GetSecs;
                end
            end
            if ~ DEBUG
                [status errorMessage] = NetStation('Event', arg{1}, Duration);
                if status % non-zero status means there was a problem
                    fprintf('[NETSTATION] Error: %s\n', errorMessage);
                    ExitStudy(errorMessage);
                    return
                end
            end
        end
        % if one isn't found, use GetSecs()
    else % unknown code
        fprintf('Unrecognized command: ');
        disp(arg)
        Failed=1;
        ErrorMessage='[SendTrigger]: Unknown command';
        return
    end
end