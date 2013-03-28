% testing PTB

% hide the cursor
HideCursor;

TEST_START = GetSecs();
% ===
% Test 1: Get the ScreenID of the "top" screen and open a window on that
% screen, report:
%   - window ID
%   - size of the window
%   - flip interval
% if the test fails, close the windows
% ===
Test1 = 1;
try 
    Test1Start = GetSecs() - TEST_START;
    ScreenID = max(Screen('Screens'));
    Priority(0);
    [ WINDOW WINDOW_RECT ] = Screen('OpenWindow', ScreenID, [192 192 192], [], [], 2);
    [ IFI nvalid stddev ] = Screen('GetFlipInterval', WINDOW, 100, 0.00005, 20);
    fprintf('Window ID is: %g\n', WINDOW);
    fprintf('Window size is (%g, %g, %g, %g)\n', WINDOW_RECT(:));
    fprintf('Flip interval is: %g\n', IFI);
catch ME
    Screen('CloseAll');
    Test1 = 0;
    rethrow(ME);
end
Test1End = GetSecs() - TEST_START;
fprintf('=========\n');
fprintf('Test1 Begin:\t%g\n',Test1Start);
fprintf('Test1 End:\t%g secs\n', Test1End);
fprintf('Test1 time elapsed: %g secs\n', Test1End - Test1Start);
if Test1
    fprintf('Test1 was successful.\n');
else
    fprintf('Test1 failed.\n');
end

%{
% ===
% Test 2: Display the text "Please wait..." and wait for 2 seconds.  
% Report:
%   - when the test began
%   - when the text was drawn
%   - when the text was flipped
Test2Start = GetSecs() - TEST_START;
Test2 = 1;
if ~ Test1
    return
end
try
    DrawFormattedText(WINDOW, 'Test2', 'center', 'center',[0 0 0]);
    Screen('Flip',WINDOW);
    pause(1);
    
    String = 'TEST2:\nPlease wait';
    DrawStart = GetSecs() - TEST_START;
    [nx ny textbounds] = DrawFormattedText(WINDOW, String, 'center', 'center',...
        [0 0 0]);
    %Screen('DrawingFinished', WINDOW,0);
    DrawEnd = GetSecs() - TEST_START;
    % flip the window, but allow for future drawing (param4 = 1)
    [t2_vbltime t2_sostime t2_fliptime missed beampos]=Screen('Flip',WINDOW,0,1);
    if missed>0
        fprintf('Deadline missed: Test2\n');
    end
    pause(2)
catch ME
    Screen('CloseAll');
    Test2 = 0;
    rethrow(ME);
end
Test2End = GetSecs() - TEST_START;
fprintf('=========\n');
fprintf('Test2 Begin:\t%g secs\n', Test2Start);
fprintf('Test2 End:\t%g secs\n', Test2End);
fprintf('Test2 time elapsed: %g secs\n', Test2End - Test2Start);
if Test2
    fprintf('Draw Begin:\t%g secs\n', DrawStart);
    fprintf('Draw End:\t%g secs\n', DrawEnd);
    fprintf('FlipTime:\t%g secs\n', t2_fliptime - TEST_START);
    fprintf('TextOnset:\t%g secs\n', t2_sostime - TEST_START);
    fprintf('Test2 was successful.\n');
else
    fprintf('Test2 failed.\n');
end

% ===
% Test 3: Add a period ('.') one third of a screen below previous text
% and wait 2 seconds.  Report:
%   - when the test began
%   - when the text was drawn
%   - when the text was flipped
Test3Start = GetSecs() - TEST_START;
Test3 = 1;
if ~ Test1
    return
end
try
    %DrawFormattedText(WINDOW, 'Test3', 'center', 'center',[0 0 0]);
    %Screen('Flip',WINDOW);
    %pause(1);
    
    % calculate one third of the screen height
    Third = round(WINDOW_RECT(4)/3);
    DrawStart = GetSecs() - TEST_START;
    [nx2 ny2 textbounds2] = DrawFormattedText(WINDOW, 'TEST3:\n.', 'center', ny + Third,...
        [0 0 0]);
    Screen('DrawingFinished', WINDOW,0);
    DrawEnd = GetSecs() - TEST_START;
    % draw the '.' at the next refresh cycle
    [t3_vbltime t3_sostime t3_fliptime missed beampos]=Screen('Flip',WINDOW);
    if missed>0
        fprintf('Deadline missed: Test3\n');
    end
    pause(2);

catch ME
    Screen('CloseAll');
    Test3 = 0;
    rethrow(ME);
end
Test3End = GetSecs() - TEST_START;
fprintf('=========\n');
fprintf('Test3 Begin:\t%g secs\n', Test3Start);
fprintf('Test3 End:\t%g secs\n', Test3End);
fprintf('Test3 time elapsed: %g secs\n', Test3End - Test3Start);
if Test3
    fprintf('Draw Begin:\t%g secs\n', DrawStart);
    fprintf('Draw End:\t%g secs\n', DrawEnd);
    fprintf('FlipTime:\t%g secs\n', t3_fliptime - TEST_START);
    fprintf('TextOnset:\t%g secs\n', t3_sostime - TEST_START);
    fprintf('Test3 was successful.\n');
else
    fprintf('Test3 failed.\n');
end

% ===
% Test 4: Display the text "Please wait<third_screen>." and wait for the user
% to press 'q'.  Report:
%   - when the test began
%   - when the text was drawn
%   - when the text was flipped
%   - when the user pressed 'q'
Test4Start = GetSecs() - TEST_START;
Test4 = 1;
if ~ Test1
    return
end
try
    DrawFormattedText(WINDOW, 'Test4', 'center', 'center',[0 0 0]);
    Screen('Flip',WINDOW);
    pause(1);
    
    % draw 'Please wait'
    String = 'Please wait';
    DrawStart = GetSecs() - TEST_START;
    [nx ny textbounds] = DrawFormattedText(WINDOW, String, 'center', 'center',...
        [0 0 0]);
    DrawEnd1 = GetSecs() - TEST_START;
    % add '.' to bottom
    [nx2 ny2 textbounds2] = DrawFormattedText(WINDOW, 'TEST4_2: [Press ''q'' to continue]\n.', 'center', ny + Third,...
        [0 0 0]);
    DrawEnd2 = GetSecs() - TEST_START;
    % tell PTB drawing is finished
    Screen('DrawingFinished', WINDOW,0);
    

    [t4_vbltime t4_sostime t4_fliptime missed beampos]=Screen('Flip',WINDOW);
    if missed>0
        fprintf('Deadline missed: Test4\n');
    end
    % get user response
    KbName('UnifyKeyNames');
    ValidKeys={'q'};
    
    KeepChecking = 1;
    while KeepChecking
        pause(.05);
        [keyIsDown secs keyCode ] = KbCheck;
        % check if key was pressed
        if keyIsDown
            keyPressed = KbName(find(keyCode));
            % ignore key press if not in ValidKeys
            if ismember(keyPressed, ValidKeys)
                switch keyPressed
                    case 'q'
                        KeepChecking = 0;
                        KeyPressTime = secs - TEST_START;
                end
            end % end if ismember(keyPressed, ValidKeys)
        end
    end

catch ME
    Screen('CloseAll');
    Test4 = 0;
    rethrow(ME);
end
Test4End = GetSecs() - TEST_START;
fprintf('=========\n');
fprintf('Test4 Begin:\t%g secs\n', Test4Start);
fprintf('Test4 End:\t%g secs\n', Test4End);
fprintf('Test4 time elapsed: %g secs\n', Test4End - Test4Start);
if Test4
    fprintf('Draw Begin:\t%g secs\n', DrawStart);
    fprintf('Draw End:\t%g secs\n', DrawEnd1);
    fprintf('Draw End2:\t%g secs\n', DrawEnd2);
    fprintf('FlipTime:\t%g secs\n', t4_fliptime - TEST_START);
    fprintf('TextOnset:\t%g secs\n', t4_sostime - TEST_START);
    fprintf('''q'' was pressed at: %g secs\n', KeyPressTime);
    fprintf('Time from TextOnset to ''q'' press: %g secs\n', KeyPressTime - t4_sostime + TEST_START);
    fprintf('Test4 was successful.\n');
else
    fprintf('Test4 failed.\n');
end


% ===
% Test 5: Display the text "Please wait<third_screen>." and wait for the user
% to press 'q'.  After 'q' press, remove '.'.  Report:
%   - when the test began
%   - when the text was drawn
%   - when the text was flipped
%   - when the user pressed 'q'
%   - when the period was removed
%   - when the new screen was flipped
Test5Start = GetSecs() - TEST_START;
Test5 = 1;
if ~ Test1
    return
end
try
    DrawFormattedText(WINDOW, 'Test5', 'center', 'center',[0 0 0]);
    Screen('Flip',WINDOW);
    pause(1);
    
    % draw 'Please wait'
    String = 'TEST5: [Press ''q'' to continue]\nPlease wait';
    DrawStart = GetSecs() - TEST_START;
    [nx ny textbounds] = DrawFormattedText(WINDOW, String, 'center', 'center',...
        [0 0 0]);
    DrawEnd1 = GetSecs() - TEST_START;
    % add '.' to bottom
    [nx2 ny2 textbounds2] = DrawFormattedText(WINDOW, '.', 'center', ny + Third,...
        [0 0 0]);
    DrawEnd2 = GetSecs() - TEST_START;
    % tell PTB drawing is finished
    Screen('DrawingFinished', WINDOW,0);
    

    [t5_vbltime t5_sostime t5_fliptime missed beampos]=Screen('Flip',WINDOW);
    if missed>0
        fprintf('Deadline missed: Test5\n');
    end
    % get user response
    KbName('UnifyKeyNames');
    ValidKeys={'q'};
    
    KeepChecking = 1;
    while KeepChecking
        pause(.05);
        [keyIsDown secs keyCode ] = KbCheck;
        % check if key was pressed
        if keyIsDown
            keyPressed = KbName(find(keyCode));
            % ignore key press if not in ValidKeys
            if ismember(keyPressed, ValidKeys)
                switch keyPressed
                    case 'q'
                        KeepChecking = 0;
                        KeyPressTime = secs - TEST_START;
                end
            end % end if ismember(keyPressed, ValidKeys)
        end
    end
    
     % draw 'Please wait' without '.'
    String = 'Please wait';
    DrawStart2 = GetSecs() - TEST_START;
    [nx ny textbounds] = DrawFormattedText(WINDOW, String, 'center', 'center',...
        [0 0 0]);
    DrawEnd3 = GetSecs() - TEST_START;
    Screen('DrawingFinished', WINDOW,0);

    [t5_vbltime2 t5_sostime2 t5_fliptime2 missed beampos]=Screen('Flip',WINDOW);
    pause(2)
catch ME
    Screen('CloseAll');
    Test5 = 0;
    rethrow(ME);
end
Test5End = GetSecs() - TEST_START;
fprintf('=========\n');
fprintf('Test5 Begin:\t%g secs\n', Test5Start);
fprintf('Test5 End:\t%g secs\n', Test5End);
fprintf('Test5 time elapsed: %g secs\n', Test5End - Test5Start);
if Test5
    fprintf('Draw text Begin:\t%g secs\n', DrawStart);
    fprintf('Draw text End:\t%g secs\n', DrawEnd1);
    fprintf('Draw period End2:\t%g secs\n', DrawEnd2);
    fprintf('FlipTime:\t%g secs\n', t5_fliptime - TEST_START);
    fprintf('TextOnset:\t%g secs\n', t5_sostime - TEST_START);
    fprintf('''q'' was pressed at: %g secs\n', KeyPressTime);
    fprintf('Time from TextOnset to ''q'' press: %g secs\n', KeyPressTime - t5_sostime + TEST_START);
    fprintf('Draw text2 Begin:\t%g secs\n', DrawStart2);
    fprintf('Draw text2 End:\t%g secs\n', DrawEnd3);
    fprintf('FlipTime:\t%g secs\n', t5_fliptime2 - TEST_START);
    fprintf('TextOnset:\t%g secs\n', t5_sostime2 - TEST_START);
    fprintf('Test5 was successful.\n');
else
    fprintf('Test5 failed.\n');
end
%}


% ===
% Test 6: Read in an image and create a texture from it, then 
% display that image for 1 second. Report:
%   - when the test began
%   - when the image was read
%   - when the texture was created
%   - when the texture was drawn
%   - when the new screen was flipped
%   - when the second started
%   - when the second ended
Test6Start = GetSecs() - TEST_START;
Test6 = 1;
if ~ Test1
    return
end
try
    DrawFormattedText(WINDOW, 'Test6', 'center', 'center',[0 0 0]);
    [vbl TestOnset] = Screen('Flip',WINDOW);
    pause(1);
    
    Image=['jpgs',filesep,'dog.jpg'];
    % read in image
    Picture1 = imread(Image, 'jpg');
    ReadTime = GetSecs();
    
    % create texture
    Texture1 = Screen('MakeTexture', WINDOW, Picture1);
    CreateTime = GetSecs();
    
    % draw texture
    Screen('DrawTexture', WINDOW, Texture1);
    DrawTime = GetSecs();
    Screen('DrawingFinished', WINDOW);
        
    % flip screen
    [t6_vbltime t6_sostime t6_fliptime missed beampos]=Screen('Flip',WINDOW,ReadTime+IFI);
    if missed>0
        fprintf('Deadline missed: Test6\n');
    end
    
    % close textures
    Screen('Close', Texture1);
    
    % wait one second
    PauseStart = GetSecs();
    pause(1);
    PauseEnd = GetSecs();
    
catch ME
    Screen('CloseAll');
    Test6 = 0;
    rethrow(ME);
end
Test6End = GetSecs() - TEST_START;
fprintf('=========\n');
fprintf('Test6 Begin:\t%g secs\n', Test6Start);
fprintf('Test6 End:\t%g secs\n', Test6End);
fprintf('Test6 time elapsed: %g secs\n', Test6End - Test6Start);
if Test6
    fprintf('ReadImage:\t%g secs\n', ReadTime - TEST_START);
    fprintf('CreateTexture:\t%g secs\n', CreateTime - TEST_START);
    fprintf('DrawTexture:\t%g secs\n', DrawTime - TEST_START);
    fprintf('FlipTime:\t%g secs\n', t6_fliptime - TEST_START);
    fprintf('TextOnset:\t%g secs\n', t6_sostime - TEST_START);
    fprintf('PauseStart:\t%g secs\n', PauseStart - TEST_START);
    fprintf('PauseEnd:\t%g secs\n', PauseEnd - TEST_START);
    fprintf('Test6 was successful.\n');
else
    fprintf('Test6 failed.\n');
end


% ===
% Test 7: Read in a series of images and create a textures from them, then 
% display them for 1, .2 and 1 seconds, respectively. Report:
%   - when the test began
%   - when the images were read
%   - when the textures were created
%   - when the textures were drawn
%   - when the new screens were flipped
%   - when the timing started
%   - when the timing ended
Test7Start = GetSecs() - TEST_START;
Test7 = 1;
if ~ Test1
    return
end
try
    DrawFormattedText(WINDOW, 'Test7', 'center', 'center',[0 0 0]);
    [vbl TestOnset] = Screen('Flip',WINDOW);
    pause(1);
    
    Image1=['jpgs',filesep,'dog.jpg'];
    Image2=['jpgs',filesep,'cow.jpg'];
    Image3=['jpgs',filesep,'pig.jpg'];
    
    % read in images
    Picture1 = imread(Image1, 'jpg');
    ReadTime1 = GetSecs();
    Picture2 = imread(Image2, 'jpg');
    ReadTime2 = GetSecs();
    Picture3 = imread(Image3, 'jpg');
    ReadTime3 = GetSecs();
    
    % create textures
    Texture1 = Screen('MakeTexture', WINDOW, Picture1);
    CreateTime1 = GetSecs();
    Texture2 = Screen('MakeTexture', WINDOW, Picture2);
    CreateTime2 = GetSecs();
    Texture3 = Screen('MakeTexture', WINDOW, Picture3);
    CreateTime3 = GetSecs();
    
    % draw textures, waiting the appropriate amount of time
    % ===
    % Texture1
    % ===
    Screen('DrawTexture', WINDOW, Texture1);
    DrawTime1 = GetSecs();
    Screen('DrawingFinished', WINDOW);
        
    % flip screen
    [t7_vbltime1 t7_sostime1 t7_fliptime1 missed1 beampos1]=Screen('Flip',WINDOW,TestOnset+IFI);
    if missed1>0
        fprintf('Deadline missed: Test7\n');
    end
    
    % ===
    % Texture2
    % ===
    Screen('DrawTexture', WINDOW, Texture2);
    DrawTime2 = GetSecs();
    Screen('DrawingFinished', WINDOW);
        
    % flip screen
    [t7_vbltime2 t7_sostime2 t7_fliptime2 missed2 beampos2]=Screen('Flip',WINDOW,...
        t7_sostime1 + IFI + 1);
    if missed2>0
        fprintf('Deadline missed: Test7\n');
    end
    
    % ===
    % Texture3
    % ===
    Screen('DrawTexture', WINDOW, Texture3);
    DrawTime3 = GetSecs();
    Screen('DrawingFinished', WINDOW);
        
    % flip screen
    [t7_vbltime3 t7_sostime3 t7_fliptime3 missed3 beampos3]=Screen('Flip',WINDOW,...
        t7_sostime2 + IFI + .2);
    if missed3>0
        fprintf('Deadline missed: Test7\n');
    end
    
    % close textures
    Screen('Close', Texture1);
    Screen('Close', Texture2);
    Screen('Close', Texture3);
    
    % wait one second
    PauseStart3 = GetSecs();
    pause(1);
    PauseEnd3 = GetSecs();
    
catch ME
    Screen('CloseAll');
    Test7 = 0;
    rethrow(ME);
end
Test7End = GetSecs() - TEST_START;
fprintf('=========\n');
fprintf('Test7 Begin:\t%g secs\n', Test7Start);
fprintf('Test7 End:\t%g secs\n', Test7End);
fprintf('Test7 time elapsed: %g secs\n', Test7End - Test7Start);
if Test7
    fprintf('ReadImage1:\t%g secs\n', ReadTime1 - TEST_START);
    fprintf('ReadImage2:\t%g secs\n', ReadTime2 - TEST_START);
    fprintf('ReadImage3:\t%g secs\n', ReadTime3 - TEST_START);
    fprintf('CreateTexture1:\t%g secs\n', CreateTime1 - TEST_START);
    fprintf('CreateTexture2:\t%g secs\n', CreateTime2 - TEST_START);
    fprintf('CreateTexture3:\t%g secs\n', CreateTime3 - TEST_START);
    fprintf('DrawTexture1:\t%g secs\n', DrawTime1 - TEST_START);
    fprintf('DrawTexture2:\t%g secs\n', DrawTime2 - TEST_START);
    fprintf('DrawTexture3:\t%g secs\n', DrawTime3 - TEST_START);
    fprintf('FlipTime1:\t%g secs\n', t7_fliptime1 - TEST_START);
    fprintf('StimOnset1:\t%g secs\n', t7_sostime1 - TEST_START);
    fprintf('FlipTime2:\t%g secs\n', t7_fliptime2 - TEST_START);
    fprintf('StimOnset2:\t%g secs\n', t7_sostime2 - TEST_START);
    fprintf('FlipTime3:\t%g secs\n', t7_fliptime3 - TEST_START);
    fprintf('StimOnset3:\t%g secs\n', t7_sostime3 - TEST_START);
    fprintf('PauseStart3:\t%g secs\n', PauseStart3 - TEST_START);
    fprintf('PauseEnd3:\t%g secs\n', PauseEnd3 - TEST_START);
    fprintf('Test7 was successful.\n');
else
    fprintf('Test7 failed.\n');
end

%{
% ===
% Test 8: Read in a series of images and create a textures from them, then 
% display them for 1, .2 and 1 seconds, respectively.  Then draw a response
% area underneath the last picture.  Report:
%   - when the test began
%   - when the images were read
%   - when the textures were created
%   - when the textures were drawn
%   - when the new screens were flipped
%   - when the timing started
%   - when the timing ended
%   - when response area was defined
%   - when resonse area was drawn

Test8Start = GetSecs() - TEST_START;
Test8 = 1;
if ~ Test1
    return
end
try
    DrawFormattedText(WINDOW, 'Test8', 'center', 'center',[0 0 0]);
    Screen('Flip',WINDOW);
    pause(1);
    
    Image1=['jpgs',filesep,'dog.jpg'];
    Image2=['jpgs',filesep,'cow.jpg'];
    Image3=['jpgs',filesep,'pig.jpg'];
    
    % read in images
    Picture1 = imread(Image1, 'jpg');
    ReadTime1 = GetSecs();
    Picture2 = imread(Image2, 'jpg');
    ReadTime2 = GetSecs();
    Picture3 = imread(Image3, 'jpg');
    ReadTime3 = GetSecs();
    
    % create textures
    Texture1 = Screen('MakeTexture', WINDOW, Picture1);
    CreateTime1 = GetSecs();
    Texture2 = Screen('MakeTexture', WINDOW, Picture2);
    CreateTime2 = GetSecs();
    Texture3 = Screen('MakeTexture', WINDOW, Picture3);
    CreateTime3 = GetSecs();
    
    % draw textures, waiting the appropriate amount of time
    % ===
    % Texture1
    % ===
    Screen('DrawTexture', WINDOW, Texture1);
    DrawTime1 = GetSecs();
    Screen('DrawingFinished', WINDOW);
        
    % flip screen
    [t8_vbltime1 t8_sostime1 t8_fliptime1 missed1 beampos1]=Screen('Flip',WINDOW);
    if missed1>0
        fprintf('Deadline missed: Test8\n');
    end
    
    % ===
    % Texture2
    % ===
    Screen('DrawTexture', WINDOW, Texture2);
    DrawTime2 = GetSecs();
    Screen('DrawingFinished', WINDOW);
        
    % flip screen
    [t8_vbltime2 t8_sostime2 t8_fliptime2 missed2 beampos2]=Screen('Flip',WINDOW,...
        t8_sostime1 + IFI + 1);
    if missed2>0
        fprintf('Deadline missed: Test8\n');
    end
    
    % ===
    % Texture3
    % ===
    Screen('DrawTexture', WINDOW, Texture3);
    DrawTime3 = GetSecs();
        
    % flip screen
    [t8_vbltime3 t8_sostime3 t8_fliptime3 missed3 beampos3]=Screen('Flip',WINDOW,...
        t8_sostime2 + IFI + .2,1);
    if missed3>0
        fprintf('Deadline missed: Test8\n');
    end
    
    % wait one second
    PauseStart3 = GetSecs();
    pause(1);
    PauseEnd3 = GetSecs();
    
    % Get ready to draw the Response area
    BoxWidth = 80; % cause I said so
    BoxPadding = 10; % cause I said so
    TopEdge = 530; % cause I said so

    FirstValue = 3;
    Boxes = 7;
    MaxDuration = 10;

    % store the FirstValue in CurrentBox
    CurrentBox = FirstValue+1;
    % get the Response area dimensions
    fprintf('Drawing %g boxes, with box %g selected...\n', Boxes, FirstValue);
    [BoxesRect BoxesColor] = DrawResponseArea(Boxes, BoxWidth, BoxPadding, TopEdge);
    DefinedTime = GetSecs();
    
    CurrentColor = BoxesColor;
    CurrentColor(:,CurrentBox) = [0 0 255];

    % Draw response area
    Screen('FillRect', WINDOW, CurrentColor, BoxesRect);
    Screen('DrawingFinished', WINDOW);
    % display the response area
    [LikertVBLTime LikertOnsetTime LikertFlipTime Miss Beampos] = Screen('Flip', WINDOW, 0 ,1);

    pause(2)
    
catch ME
    Screen('CloseAll');
    Test8 = 0;
    rethrow(ME);
end
Test8End = GetSecs() - TEST_START;
fprintf('=========\n');
fprintf('Test8 Begin:\t%g secs\n', Test8Start);
fprintf('Test8 End:\t%g secs\n', Test8End);
fprintf('Test8 time elapsed: %g secs\n', Test8End - Test8Start);
if Test8
    fprintf('ReadImage1:\t%g secs\n', ReadTime1 - TEST_START);
    fprintf('ReadImage2:\t%g secs\n', ReadTime2 - TEST_START);
    fprintf('ReadImage3:\t%g secs\n', ReadTime3 - TEST_START);
    fprintf('CreateTexture1:\t%g secs\n', CreateTime1 - TEST_START);
    fprintf('CreateTexture2:\t%g secs\n', CreateTime2 - TEST_START);
    fprintf('CreateTexture3:\t%g secs\n', CreateTime3 - TEST_START);
    fprintf('DrawTexture1:\t%g secs\n', DrawTime1 - TEST_START);
    fprintf('DrawTexture2:\t%g secs\n', DrawTime2 - TEST_START);
    fprintf('DrawTexture3:\t%g secs\n', DrawTime3 - TEST_START);
    fprintf('FlipTime1:\t%g secs\n', t8_fliptime1 - TEST_START);
    fprintf('StimOnset1:\t%g secs\n', t8_sostime1 - TEST_START);
    fprintf('FlipTime2:\t%g secs\n', t8_fliptime2 - TEST_START);
    fprintf('StimOnset2:\t%g secs\n', t8_sostime2 - TEST_START);
    fprintf('FlipTime3:\t%g secs\n', t8_fliptime3 - TEST_START);
    fprintf('StimOnset3:\t%g secs\n', t8_sostime3 - TEST_START);
    fprintf('PauseStart3:\t%g secs\n', PauseStart3 - TEST_START);
    fprintf('PauseEnd3:\t%g secs\n', PauseEnd3 - TEST_START);
    fprintf('ResponseArea defined:\t%g secs\n', DefinedTime - TEST_START);
    fprintf('ResponseArea flipped:\t%g secs\n', LikertOnsetTime - TEST_START);
    fprintf('Test8 was successful.\n');
else
    fprintf('Test8 failed.\n');
end
%}

% ===
% Test 9: Read in a series of images and create a textures from them, then 
% display them for 1, .2 and 1 seconds, respectively.  Then draw a response
% area underneath the last picture.  Then record responsea and update the
% response area based on responses until response is 'DownArrow'. Report:
%   - when the test began
%   - when the images were read
%   - when the textures were created
%   - when the textures were drawn
%   - when the new screens were flipped
%   - when the timing started
%   - when the timing ended
%   - when response area was defined
%   - when resonse area was drawn
%   - when each response was pressed
%   - when the screen was redrawn
%   - when 'DownArrow' was pressed

Test9Start = GetSecs() - TEST_START;
Test9 = 1;
if ~ Test1
    return
end
try
    KeyPresses=[];
    KeyPressTimes=[];
    ResponseRedraws=[];
    
    DrawFormattedText(WINDOW, 'Test9', 'center', 'center',[0 0 0]);
    Screen('Flip',WINDOW);
    pause(1);
    
    Image1=['jpgs',filesep,'dog.jpg'];
    Image2=['jpgs',filesep,'cow.jpg'];
    Image3=['jpgs',filesep,'pig.jpg'];
    
    % read in images
    Picture1 = imread(Image1, 'jpg');
    ReadTime1 = GetSecs();
    Picture2 = imread(Image2, 'jpg');
    ReadTime2 = GetSecs();
    Picture3 = imread(Image3, 'jpg');
    ReadTime3 = GetSecs();
    
    % create textures
    Texture1 = Screen('MakeTexture', WINDOW, Picture1);
    CreateTime1 = GetSecs();
    Texture2 = Screen('MakeTexture', WINDOW, Picture2);
    CreateTime2 = GetSecs();
    Texture3 = Screen('MakeTexture', WINDOW, Picture3);
    CreateTime3 = GetSecs();
    
    % draw textures, waiting the appropriate amount of time
    % ===
    % Texture1
    % ===
    Screen('DrawTexture', WINDOW, Texture1);
    DrawTime1 = GetSecs();
    Screen('DrawingFinished', WINDOW);
        
    % flip screen
    [t9_vbltime1 t9_sostime1 t9_fliptime1 missed1 beampos1]=Screen('Flip',WINDOW);
    if missed1>0
        fprintf('Deadline missed: Test9\n');
    end
    
    % ===
    % Texture2
    % ===
    Screen('DrawTexture', WINDOW, Texture2);
    DrawTime2 = GetSecs();
    Screen('DrawingFinished', WINDOW);
        
    % flip screen
    [t9_vbltime2 t9_sostime2 t9_fliptime2 missed2 beampos2]=Screen('Flip',WINDOW,...
        t9_sostime1 + IFI + 1);
    if missed2>0
        fprintf('Deadline missed: Test9\n');
    end
    
    % ===
    % Texture3
    % ===
    Screen('DrawTexture', WINDOW, Texture3);
    DrawTime3 = GetSecs();
        
    % flip screen
    [t9_vbltime3 t9_sostime3 t9_fliptime3 missed3 beampos3]=Screen('Flip',WINDOW,...
        t9_sostime2 + IFI + .2,1);
    if missed3>0
        fprintf('Deadline missed: Test9\n');
    end
    
    % wait one second
    PauseStart3 = GetSecs();
    pause(1);
    PauseEnd3 = GetSecs();
    
    % Get ready to draw the Response area
    BoxWidth = 80; % cause I said so
    BoxPadding = 10; % cause I said so
    TopEdge = 530; % cause I said so

    FirstValue = 3;
    Boxes = 7;
    MaxDuration = 10;

    % store the FirstValue in CurrentBox
    CurrentBox = FirstValue+1;
    %fprintf('[%s] Current box is %g\n', GetTime(), CurrentBox);
    % draw the Response area
    fprintf('Drawing %g boxes, with box %g selected...\n', Boxes, FirstValue);
    [BoxesRect BoxesColor] = DrawResponseArea(Boxes, BoxWidth, BoxPadding, TopEdge);
    DefinedTime = GetSecs();

    CurrentColor = BoxesColor;
    CurrentColor(:,CurrentBox) = [0 0 255];


    KbName('UnifyKeyNames');
    ValidKeys={'q', 'RightArrow', 'DownArrow', 'LeftArrow','7','8','9'};

    % Draw response area without overwriting the current screen???
    Screen('FillRect', WINDOW, CurrentColor, BoxesRect);
    % display the response area
    [LikertVBLTime LikertOnsetTime LikertFlipTime Miss Beampos] = Screen('Flip', WINDOW, 0 ,1);

    KeepChecking = 1;
    while KeepChecking
        pause(.05);
        [keyIsDown secs keyCode ] = KbCheck;
        % check if key was pressed
        if keyIsDown
            keyPressed = KbName(find(keyCode));
            % ignore key press if not in ValidKeys
            if ismember(keyPressed, ValidKeys)
                fprintf('You pressed %s \n',keyPressed);
                switch keyPressed
                    case {'LeftArrow','7'}
                        KeyPresses(end+1) = 7;
                        KeyPressTimes(end+1) = secs;
                        % move CurrentBox 'left' unless already at 2
                        if CurrentBox==2
                            % do nothing
                            ResponseRedraws(end+1) = -1;
                        else
                            CurrentBox = CurrentBox - 1;
                            % reset box colors
                            CurrentColor = BoxesColor;
                            % color new current box
                            CurrentColor(:,CurrentBox) = [0 0 255];
                            Screen('FillRect', WINDOW, CurrentColor, BoxesRect);
                            [vbl onset] = Screen('Flip', WINDOW, 0, 1); % flip but don't clear previous
                            ResponseRedraws(end+1) = onset;
                        end
                    case {'RightArrow','9'}
                        KeyPresses(end+1) = 9;
                        KeyPressTimes(end+1) = secs;
                        % move CurrentBox 'right' unless already at end
                        if CurrentBox==length(BoxesRect)
                            % do nothing
                            ResponseRedraws(end+1) = -1;
                        else
                            CurrentBox = CurrentBox + 1;
                            % reset box colors
                            CurrentColor = BoxesColor;
                            % color new current box
                            CurrentColor(:,CurrentBox) = [0 0 255];
                            Screen('FillRect', WINDOW, CurrentColor, BoxesRect);
                            [vbl onset] = Screen('Flip', WINDOW, 0, 1); % flip but don't clear previous
                            ResponseRedraws(end+1) = onset;
                        end
                    case {'DownArrow','8'}
                        KeyPresses(end+1) = 8;
                        KeyPressTimes(end+1) = secs;
                        % change current box color to 'selected'
                        CurrentColor(:,CurrentBox) = [192 192 192];
                        Screen('FillRect', WINDOW, CurrentColor, BoxesRect);
                        [vbl onset] = Screen('Flip', WINDOW);
                        % "Done" key pressed at 'secs'
                        fprintf('Finished at %g\n',secs);
                        RT = secs;
                        % ignore future key presses
                        KeepChecking = 0;
                        ResponseRedraws(end+1) = onset;
                end
            else
                fprintf('===\n===\n===INVALID KEY===\n===\n');
            end % end if ismember(keyPressed, ValidKeys)
        end
    end
    %pause(2)
    
    % close textures
    Screen('Close', Texture1);
    Screen('Close', Texture2);
    Screen('Close', Texture3);
catch ME
    Screen('CloseAll');
    Test9 = 0;
    rethrow(ME);
end
Test9End = GetSecs() - TEST_START;
fprintf('=========\n');
fprintf('Test9 Begin:\t%g secs\n', Test9Start);
fprintf('Test9 End:\t%g secs\n', Test9End);
fprintf('Test9 time elapsed: %g secs\n', Test9End - Test9Start);
if Test9
    fprintf('ReadImage1:\t%g secs\n', ReadTime1 - TEST_START);
    fprintf('ReadImage2:\t%g secs\n', ReadTime2 - TEST_START);
    fprintf('ReadImage3:\t%g secs\n', ReadTime3 - TEST_START);
    fprintf('CreateTexture1:\t%g secs\n', CreateTime1 - TEST_START);
    fprintf('CreateTexture2:\t%g secs\n', CreateTime2 - TEST_START);
    fprintf('CreateTexture3:\t%g secs\n', CreateTime3 - TEST_START);
    fprintf('DrawTexture1:\t%g secs\n', DrawTime1 - TEST_START);
    fprintf('DrawTexture2:\t%g secs\n', DrawTime2 - TEST_START);
    fprintf('DrawTexture3:\t%g secs\n', DrawTime3 - TEST_START);
    fprintf('FlipTime1:\t%g secs\n', t9_fliptime1 - TEST_START);
    fprintf('StimOnset1:\t%g secs\n', t9_sostime1 - TEST_START);
    fprintf('FlipTime2:\t%g secs\n', t9_fliptime2 - TEST_START);
    fprintf('StimOnset2:\t%g secs\n', t9_sostime2 - TEST_START);
    fprintf('FlipTime3:\t%g secs\n', t9_fliptime3 - TEST_START);
    fprintf('StimOnset3:\t%g secs\n', t9_sostime3 - TEST_START);
    fprintf('PauseStart3:\t%g secs\n', PauseStart3 - TEST_START);
    fprintf('PauseEnd3:\t%g secs\n', PauseEnd3 - TEST_START);
    fprintf('ResponseArea defined:\t%g secs\n', DefinedTime - TEST_START);
    fprintf('ResponseArea flipped:\t%g secs\n', LikertOnsetTime - TEST_START);
    for i=1:length(KeyPresses)
        fprintf('[KeyPress] %d\t%g secs\tflip: %g secs\n',...
            KeyPresses(i),...
            KeyPressTimes(i) - TEST_START,...
            ResponseRedraws(i) - TEST_START);
    end
    fprintf('Test9 was successful.\n');
else
    fprintf('Test9 failed.\n');
end


% ===
% Test 10: Read in a series of images and create a textures from them, then 
% display them for 1, .2 and 1 seconds, respectively.  Then draw a response
% area underneath the last picture.  Then record responsea and update the
% response area based on responses until response is 'DownArrow', limiting
% the response time to 3 seconds.  Report:
%   - when the test began
%   - when the images were read
%   - when the textures were created
%   - when the textures were drawn
%   - when the new screens were flipped
%   - when the timing started
%   - when the timing ended
%   - when response area was defined
%   - when resonse area was drawn
%   - when each response was pressed
%   - when the screen was redrawn
%   - when 'DownArrow' was pressed
%   - when time expired
%   - how many buttons were pressed
%   - what the first button pressed was
%   - when the last button pressed was

Test10Start = GetSecs() - TEST_START;
Test10 = 1;
if ~ Test1
    return
end
try
    KeyPresses=[];
    KeyPressTimes=[];
    ResponseRedraws=[];
        
    DrawFormattedText(WINDOW, 'Test10', 'center', 'center',[0 0 0]);
    [vbl TestOnset] = Screen('Flip',WINDOW);
    pause(1);
    
    Image1=['jpgs',filesep,'dog.jpg'];
    Image2=['jpgs',filesep,'cow.jpg'];
    Image3=['jpgs',filesep,'pig.jpg'];
    
    % read in images
    Picture1 = imread(Image1, 'jpg');
    ReadTime1 = GetSecs();
    Picture2 = imread(Image2, 'jpg');
    ReadTime2 = GetSecs();
    Picture3 = imread(Image3, 'jpg');
    ReadTime3 = GetSecs();
    
    % create textures
    Texture1 = Screen('MakeTexture', WINDOW, Picture1);
    CreateTime1 = GetSecs();
    Texture2 = Screen('MakeTexture', WINDOW, Picture2);
    CreateTime2 = GetSecs();
    Texture3 = Screen('MakeTexture', WINDOW, Picture3);
    CreateTime3 = GetSecs();
    
    % draw textures, waiting the appropriate amount of time
    % ===
    % Texture1
    % ===
    Screen('DrawTexture', WINDOW, Texture1);
    DrawTime1 = GetSecs();
    Screen('DrawingFinished', WINDOW);
        
    % flip screen
    [t10_vbltime1 t10_sostime1 t10_fliptime1 missed1 beampos1]=Screen('Flip',WINDOW,TestOnset+IFI);
    if missed1>0
        fprintf('Deadline missed: Test10\n');
    end
    
    % ===
    % Texture2
    % ===
    Screen('DrawTexture', WINDOW, Texture2);
    DrawTime2 = GetSecs();
    Screen('DrawingFinished', WINDOW);
        
    % flip screen
    [t10_vbltime2 t10_sostime2 t10_fliptime2 missed2 beampos2]=Screen('Flip',WINDOW,...
        t10_sostime1 + IFI + 1);
    if missed2>0
        fprintf('Deadline missed: Test10\n');
    end
    
    % ===
    % Texture3
    % ===
    Screen('DrawTexture', WINDOW, Texture3);
    DrawTime3 = GetSecs();
        
    % flip screen
    [t10_vbltime3 t10_sostime3 t10_fliptime3 missed3 beampos3]=Screen('Flip',WINDOW,...
        t10_sostime2 + IFI + .2,1);
    if missed3>0
        fprintf('Deadline missed: Test10\n');
    end
    
    % wait one second
    PauseStart3 = GetSecs();
    pause(1);
    PauseEnd3 = GetSecs();
    
    % Get ready to draw the Response area
    BoxWidth = 80; % cause I said so
    BoxPadding = 10; % cause I said so
    TopEdge = 530; % cause I said so

    % ===
    % Response Area Values
    % ===
    FirstValue = 3;
    Boxes = 7;
    MaxDuration = 3;

    % store the FirstValue in CurrentBox
    CurrentBox = FirstValue+1;
    %fprintf('[%s] Current box is %g\n', GetTime(), CurrentBox);
    % draw the Response area
    fprintf('Drawing %g boxes, with box %g selected...\n', Boxes, FirstValue);
    [BoxesRect BoxesColor] = DrawResponseArea(Boxes, BoxWidth, BoxPadding, TopEdge);
    DefinedTime = GetSecs();

    CurrentColor = BoxesColor;
    CurrentColor(:,CurrentBox) = [0 0 255];


    KbName('UnifyKeyNames');
    ValidKeys={'q', 'RightArrow', 'DownArrow', 'LeftArrow','7','8','9'};

    % Draw response area without overwriting the current screen???
    Screen('FillRect', WINDOW, CurrentColor, BoxesRect);
    % display the response area
    [LikertVBLTime LikertOnsetTime LikertFlipTime Miss Beampos] = Screen('Flip', WINDOW, 0 ,1);

    KeepChecking = 1;
    while KeepChecking
        pause(.05);
        [keyIsDown secs keyCode ] = KbCheck;
        % check if key was pressed
        if keyIsDown
            keyPressed = KbName(find(keyCode));
            % ignore key press if not in ValidKeys
            if ismember(keyPressed, ValidKeys)
                fprintf('You pressed %s \n',keyPressed);
                switch keyPressed
                    case {'LeftArrow','7'}
                        KeyPresses(end+1) = 7;
                        KeyPressTimes(end+1) = secs;
                        % move CurrentBox 'left' unless already at 2
                        if CurrentBox==2
                            % do nothing
                            ResponseRedraws(end+1) = -1;
                        else
                            CurrentBox = CurrentBox - 1;
                            % reset box colors
                            CurrentColor = BoxesColor;
                            % color new current box
                            CurrentColor(:,CurrentBox) = [0 0 255];
                            Screen('FillRect', WINDOW, CurrentColor, BoxesRect);
                            [vbl onset] = Screen('Flip', WINDOW, 0, 1); % flip but don't clear previous
                            ResponseRedraws(end+1) = onset;
                        end
                    case {'RightArrow','9'}
                        KeyPresses(end+1) = 9;
                        KeyPressTimes(end+1) = secs;
                        % move CurrentBox 'right' unless already at end
                        if CurrentBox==length(BoxesRect)
                            % do nothing
                            ResponseRedraws(end+1) = -1;
                        else
                            CurrentBox = CurrentBox + 1;
                            % reset box colors
                            CurrentColor = BoxesColor;
                            % color new current box
                            CurrentColor(:,CurrentBox) = [0 0 255];
                            Screen('FillRect', WINDOW, CurrentColor, BoxesRect);
                            [vbl onset] = Screen('Flip', WINDOW, 0, 1); % flip but don't clear previous
                            ResponseRedraws(end+1) = onset;
                        end
                    case {'DownArrow','8'}
                        KeyPresses(end+1) = 8;
                        KeyPressTimes(end+1) = secs;
                        % change current box color to 'selected'
                        CurrentColor(:,CurrentBox) = [192 192 192];
                        Screen('FillRect', WINDOW, CurrentColor, BoxesRect);
                        [vbl onset] = Screen('Flip', WINDOW);
                        % "Done" key pressed at 'secs'
                        fprintf('Finished at %g\n',secs);
                        RT = secs;
                        % ignore future key presses
                        KeepChecking = 0;
                        ResponseRedraws(end+1) = onset;
                end
            else
                fprintf('===\n===\n===INVALID KEY===\n===\n');
            end % end if ismember(keyPressed, ValidKeys)
        end % end if keyIsDown
        if GetSecs() - LikertOnsetTime > MaxDuration
            ExpirationTime = GetSecs();
            KeepChecking = 0;
            if isempty(KeyPressTimes)
                KeyPressTimes = -1;
                ResponseRedraws = -1;
                KeyPresses = -1;
            end
            Screen('DrawingFinished', WINDOW);
            Screen('Flip',WINDOW); % flip to clear buffer
        end
    end % end KeepChecking
    
    DrawFormattedText(WINDOW, 'Test 10 Completed', 'center', 'center',[0 0 0]);
    [vbl ExpirationTime ] = Screen('Flip',WINDOW,LikertOnsetTime + MaxDuration + IFI);
    pause(1);
    
    % close textures
    Screen('Close', Texture1);
    Screen('Close', Texture2);
    Screen('Close', Texture3);
catch ME
    Screen('CloseAll');
    Test10 = 0;
    rethrow(ME);
end
Screen('CloseAll');
Test10End = GetSecs() - TEST_START;
fprintf('=========\n');
fprintf('Test10 Begin:\t%g secs\n', Test10Start);
fprintf('Test10 End:\t%g secs\n', Test10End);
fprintf('Test10 time elapsed: %g secs\n', Test10End - Test10Start);
if Test10
    fprintf('ReadImage1:\t%g secs\n', ReadTime1 - TEST_START);
    fprintf('ReadImage2:\t%g secs\n', ReadTime2 - TEST_START);
    fprintf('ReadImage3:\t%g secs\n', ReadTime3 - TEST_START);
    fprintf('CreateTexture1:\t%g secs\n', CreateTime1 - TEST_START);
    fprintf('CreateTexture2:\t%g secs\n', CreateTime2 - TEST_START);
    fprintf('CreateTexture3:\t%g secs\n', CreateTime3 - TEST_START);
    fprintf('DrawTexture1:\t%g secs\n', DrawTime1 - TEST_START);
    fprintf('DrawTexture2:\t%g secs\n', DrawTime2 - TEST_START);
    fprintf('DrawTexture3:\t%g secs\n', DrawTime3 - TEST_START);
    fprintf('FlipTime1:\t%g secs\n', t10_fliptime1 - TEST_START);
    fprintf('StimOnset1:\t%g secs\n', t10_sostime1 - TEST_START);
    fprintf('FlipTime2:\t%g secs\n', t10_fliptime2 - TEST_START);
    fprintf('StimOnset2:\t%g secs\n', t10_sostime2 - TEST_START);
    fprintf('FlipTime3:\t%g secs\n', t10_fliptime3 - TEST_START);
    fprintf('StimOnset3:\t%g secs\n', t10_sostime3 - TEST_START);
    fprintf('PauseStart3:\t%g secs\n', PauseStart3 - TEST_START);
    fprintf('PauseEnd3:\t%g secs\n', PauseEnd3 - TEST_START);
    fprintf('ResponseArea defined:\t%g secs\n', DefinedTime - TEST_START);
    fprintf('ResponseArea flipped:\t%g secs\n', LikertOnsetTime - TEST_START);
    for i=1:length(KeyPresses)
        fprintf('[KeyPress] %d\t%g secs\tflip: %g secs\n',...
            KeyPresses(i),...
            KeyPressTimes(i) - TEST_START,...
            ResponseRedraws(i) - TEST_START);
    end
    fprintf('%d key presses.\n', length(KeyPresses));
    fprintf('First key pressed:\t%g secs\n', KeyPressTimes(1) - TEST_START);
    fprintf('Expiration:\t%g secs\n', ExpirationTime - TEST_START);
    fprintf('Time from Likert onset to Expiration:\t%g secs\n', ExpirationTime - LikertOnsetTime);
    fprintf('Test10 was successful.\n');
else
    fprintf('Test10 failed.\n');
end
