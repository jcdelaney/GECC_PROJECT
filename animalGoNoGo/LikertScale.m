% LIKERT_SCALE() - Draw a Likert-style scale containing 'Boxes' number of 
% boxes.  The initial value is 'FirstValue' and the maximum duration is
% 'MaxDuration'

% subroutine to show Likert Responses based on keyboard input from the user
function [Answer RT FirstResponseTime] = LikertScale(Boxes, FirstValue, MaxDuration)
% globals
global WINDOW
global IFI
global NETSTATION
global BIOPAC
global PCPORT
global DEBUG


% reset the Response slide for use
%Response.InputMasks.Add Keyboard.CreateInputMask("678", "", Val("-1"), Val("1"), ebEndResponseActionNone, True, "", "", "")
%scale_start_time = clock.readmillisec;

% Get ready to draw the Response area
BoxWidth = 80; % cause I said so
BoxPadding = 10; % cause I said so
TopEdge = 530; % cause I said so

% if called without FirstValue, set FirstValue equal to 3
%if isMissing(FirstValue)
%	FirstValue = 3;
%end
% if called without MaxDuration, set MaxDuration equal to 3000 (3 seconds)
%if isMissing(MaxDuration)
%	MaxDuration = 3000;
%end
% store the FirstValue in CurrentBox
CurrentBox = FirstValue+1;
fprintf('[%s] Current box is %d\n', GetTime(), CurrentBox);
% draw the Response area
fprintf('Drawing %d boxes, with box %d selected...\n', Boxes, FirstValue);
[BoxesRect BoxesColor] = DrawResponseArea(Boxes, BoxWidth, BoxPadding, TopEdge);

% change the colors to draw in a blue %Response% square at the default position
%cnvs.pencolor = ccolor("cyan")
%cnvs.fillcolor = ccolor("cyan")
%cnvs.rectangle BoxArray(CurrentBox),BoxTopEdge,BoxWidth,BoxWidth
CurrentColor = BoxesColor;
CurrentColor(:,CurrentBox) = [0 0 255];

% listen for keyboard input
% =========================

% keys to control response
KbName('UnifyKeyNames')
ValidKeys = {'LeftArrow' 'DownArrow' 'RightArrow' '7' '8' '9'};

Answer = [];
RT = [];
FirstResponseTime = [];

if DEBUG
    KeepChecking = 0; 
    FirstResponse = 1;
else
    KeepChecking = 1;
    % Draw response area without overwriting the current screen???
    Screen('FillRect', WINDOW, CurrentColor, BoxesRect);
    % display the response area
    [LikertVBLTime LikertOnsetTime LikertFlipTime Miss Beampos] = Screen('Flip', WINDOW);

end

% inv: KeepChecking is true AKA either
%   1) Current time is not MaxDuration seconds longer than LikertVBLTime OR
%   2) A 'DownArrow' response was given
while KeepChecking
% if valid input, update display
    [keyIsDown secs keyCode ] = KbCheck;
    % check if key was pressed
    if keyIsDown
        keyPressed = KbName(find(keyCode));
        % ignore key press if not in ValidKeys
        if ismember(keyPressed, ValidKeys)
            switch keyPressed
                case {'LeftArrow','7'}
                    % move CurrentBox 'left' unless already at 2
                    if CurrentBox==2
                        % do nothing
                    else
                        CurrentBox = CurrentBox - 1;
                        % reset box colors
                        CurrentColor = BoxesColor;
                        % color new current box
                        CurrentColor(:,CurrentBox) = [0 0 255];
                        Screen('FillRect', WINDOW, CurrentColor, BoxesRect);
                        Screen('Flip', WINDOW, 0, 1); % flip but don't clear previous
                    end
                case {'RightArrow','9'}
                    % move CurrentBox 'right' unless already at end
                    if CurrentBox==length(BoxesRect)
                        % do nothing
                    else
                        CurrentBox = CurrentBox + 1;
                        % reset box colors
                        CurrentColor = BoxesColor;
                        % color new current box
                        CurrentColor(:,CurrentBox) = [0 0 255];
                        Screen('FillRect', WINDOW, CurrentColor, BoxesRect);
                        Screen('Flip', WINDOW, 0, 1); % flip but don't clear previous
                    end
                case {'DownArrow','8'}
                    

                    % send response to recording devices
                    if NETSTATION
                        % TODO send to netstation
                    end

                    if BIOPAC
                        lptwrite(PCPORT, CurrentBox-1); % TODO: update code number
                    end
                    
                    % change current box color to 'selected'
                    CurrentColor(:,CurrentBox) = [72 72 72];
                    Screen('FillRect', WINDOW, CurrentColor, BoxesRect);
                    Screen('Flip', WINDOW, 0, 1); % flip but don't clear previous
                    % "Done" key pressed at 'secs'
                    fprintf('Finished at %g\n',secs);
                    RT = secs;
                    % ignore future key presses
                    KeepChecking = 0;
            end
            fprintf('%s\n', keyPressed);
            if FirstResponse
                % first response was at time 'secs'
                fprintf('First press at %g\n',secs);
                FirstResponse = 0;
                FirstResponseTime = secs;
            end
            KeepChecking = 0;
        end % end if ismember(keyPressed, ValidKeys)
    end
    if GetSecs - LikertOnsetTime >= MaxDuration
        KeepChecking = 0;
    end
end

% store response
Answer = CurrentBox - 1;
% check for missed trials
if isempty(RT)
    RT = 2;
    %RT = GetSecs - LikertOnsetTime;
end
if isempty(FirstResponseTime)
    FirstResponseTime = -1;
end

% if exitting early, wait enough time to catch up to MaxDuration
%if GetSecs - LikertOnsetTime < MaxDuration
%    pause(MaxDuration - GetSecs + LikertOnsetTime - IFI);
%end
