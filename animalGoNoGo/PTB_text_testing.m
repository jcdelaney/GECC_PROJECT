% testing PTB



% ===
% Test 1: Get the ScreenID of the "top" screen and open a window on that
% screen, report:
%   - window ID
%   - size of the window
%   - flip interval
% if the test fails, close the windows
% ===
try 
    % hide the cursor
    HideCursor;

    ScreenID = max(Screen('Screens'));
    Priority(0);
    OldResolution = Screen('Resolution', ScreenID, 1024, 768);
    [ WINDOW WINDOW_RECT ] = Screen('OpenWindow', ScreenID, [192 192 192], [], [], 2);
    [ IFI nvalid stddev ] = Screen('GetFlipInterval', WINDOW, 100, 0.00005, 20);
    fprintf('Window ID is: %g\n', WINDOW);
    fprintf('Window size is (%g, %g, %g, %g)\n', WINDOW_RECT(:));
    fprintf('Flip interval is: %g\n', IFI);

catch ME
    Screen('CloseAll');
    rethrow(ME);
end

try    
    String = 'Font size test:\nPlease wait';
    DrawStart = GetSecs() - TEST_START;
    [nx ny textbounds] = DrawFormattedText(WINDOW, String, 'center', 'center',...
        [0 0 0]);
    %Screen('DrawingFinished', WINDOW,0);
    DrawEnd = GetSecs() - TEST_START;
    % flip the window)
    [t2_vbltime t2_sostime t2_fliptime missed beampos]=Screen('Flip',WINDOW);
    if missed>0
        fprintf('Deadline missed: Test2\n');
    end
    WaitSecs(.5);
    
    Question = 'How good or bad was the motive of the person who did this?';
    Anchors = {'Good', 'Neither', 'Bad'};
    QuestionOnsetTime = GetSecs();
    COLOR = [0 0 0];
    % draw question and anchors with varying font sizes
    %sizes=[48 36 28 24 20 18 16 14];
    sizes=[ 22 20 ];
    for i=1:length(sizes)
        FONT_SIZE = sizes(i);
        Screen('TextSize', WINDOW, FONT_SIZE);
        % say what the font size is
        DrawFormattedText(WINDOW, sprintf('FONT SIZE:\t%d',FONT_SIZE), 'center', 100, COLOR);
        % draw the question
        DrawFormattedText(WINDOW, Question, 'center', 181, COLOR);
        % draw the anchors
        DrawFormattedText(WINDOW, Anchors{1}, 100, 'center', COLOR);
        DrawFormattedText(WINDOW, Anchors{2}, 'center', 'center', COLOR);
        % prep Anchor3 for drawing
        DrawFormattedText(WINDOW, Anchors{3}, (WINDOW_RECT(3) - 100 - length(Anchors{3})*10), 'center', COLOR);
        % flip the question/anchors with the given font size
        [QuestionVBL QuestionOnsetTime] = Screen('Flip', WINDOW, QuestionOnsetTime + 1.5 + IFI);
    end
    WaitSecs(1);
catch ME
    Screen('CloseAll');
    rethrow(ME);
end

try
    String = 'TextFont test:\nPlease wait';
    DrawStart = GetSecs() - TEST_START;
    [nx ny textbounds] = DrawFormattedText(WINDOW, String, 'center', 'center',...
        [0 0 0]);
    %Screen('DrawingFinished', WINDOW,0);
    DrawEnd = GetSecs() - TEST_START;
    % flip the window)
    [t2_vbltime t2_sostime t2_fliptime missed beampos]=Screen('Flip',WINDOW);
    if missed>0
        fprintf('Deadline missed: Test2\n');
    end
    WaitSecs(1);
    
    Question = 'How good or bad was the motive of the person who did this?';
    Anchors = {'Good', 'Neither', 'Bad'};
    QuestionOnsetTime = GetSecs();
    COLOR = [0 0 0];
    FontNames = {'Courier New', 'Arial', 'Helvetica'};
    for f=1:length(FontNames)
        FONT_NAME = FontNames{f};
        [oldName] = Screen('TextFont',WINDOW,FONT_NAME);
        % draw question and anchors with varying font sizes
        %sizes=[48 36 28 24 20 18 16 14];
        sizes=[ 22 20 ];
        for i=1:length(sizes)
            FONT_SIZE = sizes(i);
            Screen('TextSize', WINDOW, FONT_SIZE);
            % say what the font size is
            DrawFormattedText(WINDOW, sprintf('FONT NAME: %s   FONT SIZE: %d',FONT_NAME,FONT_SIZE), 'center', 100, COLOR);
            % draw the question
            DrawFormattedText(WINDOW, Question, 'center', 181, COLOR);
            % draw the anchors
            DrawFormattedText(WINDOW, Anchors{1}, 100, 'center', COLOR);
            DrawFormattedText(WINDOW, Anchors{2}, 'center', 'center', COLOR);
            % prep Anchor3 for drawing
            DrawFormattedText(WINDOW, Anchors{3}, (WINDOW_RECT(3) - 100 - length(Anchors{3})*10), 'center', COLOR);
            % flip the question/anchors with the given font size
            [QuestionVBL QuestionOnsetTime] = Screen('Flip', WINDOW, QuestionOnsetTime + 3 + IFI);
        end
        WaitSecs(3);
    end
catch ME
    Screen('CloseAll');
    rethrow(ME);
end


% show rectangles at various lengths to determine how wide text is
try
    String = 'Text Width test:\nPlease wait';
    DrawStart = GetSecs() - TEST_START;
    [nx ny textbounds] = DrawFormattedText(WINDOW, String, 'center', 'center',...
        [0 0 0]);
    %Screen('DrawingFinished', WINDOW,0);
    DrawEnd = GetSecs() - TEST_START;
    % flip the window)
    [t2_vbltime t2_sostime t2_fliptime missed beampos]=Screen('Flip',WINDOW);
    if missed>0
        fprintf('Deadline missed: Test2\n');
    end
    WaitSecs(1);
    
    Question = 'How good or bad was the motive of the person who did this?';
    Anchors = {'Good', 'Neither', 'Bad'};
    QuestionOnsetTime = GetSecs();
    COLOR = [0 0 0];
    FontNames = {'Courier New', 'Arial', 'Helvetica'};
    for f=1:length(FontNames)
        FONT_NAME = FontNames{f};
        [oldName] = Screen('TextFont',WINDOW,FONT_NAME);
        % draw question and anchors with varying font sizes
        %sizes=[48 36 28 24 20 18 16 14];
        sizes=[ 22 20 ];
        for i=1:length(sizes)
            FONT_SIZE = sizes(i);
            Screen('TextSize', WINDOW, FONT_SIZE);
            % say what the font size is
            DrawFormattedText(WINDOW, sprintf('FONT NAME: %s   FONT SIZE: %d',FONT_NAME,FONT_SIZE), 'center', 100, COLOR);
            % draw the question
            DrawFormattedText(WINDOW, Question, 'center', 181, COLOR);
            % draw the anchors
            DrawFormattedText(WINDOW, Anchors{1}, 100, 'center', COLOR);
            DrawFormattedText(WINDOW, Anchors{2}, 'center', 'center', COLOR);
            % prep Anchor3 for drawing
            DrawFormattedText(WINDOW, Anchors{3}, (WINDOW_RECT(3) - 100 - length(Anchors{3})*FONT_SIZE), 'center', COLOR);
            % flip the question/anchors with the given font size
            [QuestionVBL QuestionOnsetTime] = Screen('Flip', WINDOW, QuestionOnsetTime + 3 + IFI);
            %{
            % draw rectangles
            widths = [10 12 15 17 20];
            for w=1:length(widths)
                WIDTH = widths(w);
                DrawFormattedText(WINDOW, sprintf('Width: %d', WIDTH), 'center', 500 + 20*w, COLOR);
                Screen('FillRect', WINDOW, [0 0 0], [600 (500+20*w) 600+WIDTH (500+20*w)+WIDTH]);
                [QuestionVBL QuestionOnsetTime] = Screen('Flip', WINDOW, QuestionOnsetTime + 3 + IFI, 1);
            end
            %}
        end
        WaitSecs(3);
    end
catch ME
    Screen('CloseAll');
    rethrow(ME);
end


Screen('CloseAll');