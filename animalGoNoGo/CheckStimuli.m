% Given a list of image paths, displays each image, one after another,
% listing the name of the image at the top of the screen.  
%   To move between images, use left/right arrow keys or 'j'/'k'.  
%   To exit, hit 'q' or ESC
%   To mark an images as "bad" hit 'b' or 'm'
%
% Usage:
%   >> [bad] = CheckStimuli(StimPaths)
function bad = CheckStimuli(StimPaths)

bad=struct();

try
    % set up keyboard responses
    KbName('UnifyKeyNames');
    LEFT=KbName({'LeftArrow','j','7','7&'});
    RIGHT=KbName({'RightArrow','k','9','9('});
    MARK=KbName({'b','m','8','8*'});
    QUIT=KbName({'q','ESCAPE','6','6^','0','0)'});
    
    [keyIsDown secs keyCode ] = KbCheck(-3);
    
    % open a window
    HideCursor;
    ScreenID = max(Screen('Screens'));
    Priority(1); % make the study high-priority (but not real-time)
    % modify the screen resolution to be 1024 x 768
    Screen('Resolution', ScreenID, 1024, 768);
    % open a window
    [ WINDOW WINDOW_RECT ] = Screen('OpenWindow', ScreenID, [192 192 192], [], [], 2);
    % get the flip interval
    [ IFI ] = Screen('GetFlipInterval', WINDOW, 100, 0.00005, 20);
    
    resp = 0;
    
    % draw the first image
    DrawImage(StimPaths{1}, bad, WINDOW);
    
    i=1;
    % inv: images 1..i have been shown on screen, and any marks added to
    % bad, also QUIT has not been hit
    while ~(sum(keyCode(QUIT)))
        % check for response
        [keyIsDown secs keyCode] = KbCheck(-3);
        if keyIsDown, 
            resp = 1; 
        end
        if resp
            if sum(keyCode(LEFT))
                % back up one image
                if i>1
                    i=i-1;
                    DrawImage(StimPaths{i}, bad, WINDOW);
                end
                resp = 0;
            elseif sum(keyCode(RIGHT))
                % advance an image
                if i<length(StimPaths)
                    i=i+1;
                    DrawImage(StimPaths{i}, bad, WINDOW);
                end
                resp = 0;
            elseif sum(keyCode(MARK))
                % mark the image
                [path name ext] = fileparts(StimPaths{i});
                bad.(name) = StimPaths{i};
                resp = 0;
                DrawImage(StimPaths{i}, bad, WINDOW);
            end
        end
        WaitSecs(0.05);
        
    end
catch ME
    Screen('CloseAll');
    rethrow(ME);
end
Screen('CloseAll');
   



function DrawImage(path, bad, WINDOW)

% get list of bad fields
BadImages = fieldnames(bad);

% draw image name
[fpath name ext] = fileparts(path);
[x y txtbounds] = DrawFormattedText(WINDOW, name, 'center', 100, [0 0 0]);


% if it's been marked, add a star
if ismember(name, BadImages)
    DrawFormattedText(WINDOW, '***','center',150,[0 0 0]);
end

% load the image
Pic = imread(path, 'bmp');
% create the texture
Texture = Screen('MakeTexture', WINDOW, Pic);
% draw the texture
Screen('DrawTexture',WINDOW,Texture);
% flip the screen
Screen('Flip',WINDOW);
% close the texture
Screen('Close',Texture);





