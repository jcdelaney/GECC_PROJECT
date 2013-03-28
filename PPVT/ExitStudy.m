% close open windows and log files
%   works whether or not PTB is installed
%
% Usage:
%   >> ExitStudy
%   OR
%   >> ExitStudy(Error)
%
% Parameters:
%   Error   message to be written to the log and the command window
%
function ExitStudy(varargin)
% declare globals
global LOGID
global DEBUG
global NETSTATION
global BIOPAC
global PCPORT

% if using NetStation, stop recording and disconnect
if NETSTATION
    try 
        NetStation('Event',9999); % send AAAGH! code
        NetStation('StopRecording');
        NetStation('Disconnect');
    catch ME
        % eat any resulting errors
    end
end

% if using BIOPAC, set to 0
if BIOPAC
    try
        lptwrite(PCPORT, 0);
    catch
        % eat any resulting errors
    end
end

if ~DEBUG
    % return keyboard output to matlab window
    ListenChar(0);
    % return the priority to 0
    Priority(0);
    % close all open Screen windows
    try
        Screen('CloseAll');
    catch ME1
        if strcmp(ME1.identifier,'MATLAB:UndefinedFunction')
            % ignore "no Screen" errors in case error occurred BECAUSE of screen problems
        else
            fprintf('[ExitStudy] MATLAB ERROR: %s\n', ME1.message);
        end
    end
end

Error = [];
if nargin>0
    Error = varargin{1};
end
% print error to log file
if ~isempty(Error)
    fprintf('[ExitStudy] ');
    disp(Error)
    try
        fprintf(LOGID,'//[ExitStudy] %s\n',Error);
    catch ME2
        if strcmp(ME2.identifier,'MATLAB:badfid_mx')
            % ignore FID errors in case error occurred BECAUSE of LOGID problems
        else
            fprintf('[ExitStudy] MATLAB ERROR: %s\n', ME2.message);
        end
    end
end

% close all open files
fclose('all');

% java heap space garbage collection
jheapcl

% explain to user what's going on
fprintf('[ExitStudy] Now closing...\n');


