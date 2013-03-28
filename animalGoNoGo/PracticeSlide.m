% Draw a training slide for subjects to practice responding
function [Failed FinishedAt] = PracticeSlide
Failed = 0;
FinishedAt = -1;

% declare globals
global WINDOW
global DEBUG
global CURRENT_RUN
global CURRENT_BLOCK
global RESPONSE_CURRENT_COLOR
global EVENT
global BOXES_COLOR
global BOXES_RECT
global IFI
global WASHOUT_DURATION
global LOGID
global BOXES
global BUTTON1
global BUTTON2
global BUTTON3
global CUE_DURATION % the duration (sec) of the cue for each block
global PIC1_DURATION % the duration (sec) of the first image in each trial
global PIC2_DURATION % the duration (sec) of the second image in each trial
global PIC3_DURATION % the duration (sec) of the third image in each trial
global RESP_DURATION % the duration (sec) of the response for each trial
global ISI % the duration (sec) of the ISI
global NUM_TRIALS
global ADVANCE
global ABORT
global ANCHOR_ORDER
global ANCHOR_VALUES
global COLOR
global WINDOW_RECT

if DEBUG
        fprintf('[PracticeSlide] Drawing practice slide...\n');
        Failed = SendTrigger(EVENT.TrainingStart,cputime);
        return
end

ISI_current = ISI(randperm(6));

CurrentTime = GetSecs();

try
    Response = 0;
    PracticeBoxes = BOXES_RECT;
    PracticeBoxes(2,:) = PracticeBoxes(2,:) - 275;
    PracticeBoxes(4,:) = PracticeBoxes(4,:) - 275;
    % load hand bmp
    Hand = imread('hand_light_gray_fingers.bmp', 'bmp');
    Texture = Screen('MakeTexture', WINDOW, Hand);
    Screen('DrawTexture', WINDOW, Texture);
    % add Anchor
    
    % store the BOXES_COLOR in local CurrentColor
    CurrentColor = BOXES_COLOR;
    % Draw response area 
    Screen('FillRect', WINDOW, CurrentColor, PracticeBoxes);
    % display the response area
    ResponseVBLTime = Screen('Flip', WINDOW, CurrentTime + IFI,1);
    % send trigger
    Failed = SendTrigger(EVENT.TrainingStart, ResponseVBLTime);
    if Failed, ExitStudy(); return; end
    
    % write to log
    fprintf(LOGID,'%d\t%d\t%10.4f\tTrainingStart\t%d\n', CURRENT_RUN, CURRENT_BLOCK, ResponseVBLTime, 1);
    
    % initialite KbCheck
    [~, ~, keyCode] = KbCheck;
    % set initial value for keyCode
    keyCode(ADVANCE) = 0;
    keyCode(ABORT) = 0;
    % loop until advance or abort key
    while ~(sum(keyCode(ADVANCE)) || sum(keyCode(ABORT)) || sum(keyCode(KbName('s'))))
        % listen for keyboard responses until RESP_DURATION
        WaitSecs(.05);
        [keyIsDown secs keyCode ] = KbCheck(-3);
        % check if key was pressed
        if keyIsDown
            keyPressed = KbName(find(keyCode));
            % check BUTTON1 mappings
            if sum(keyCode(BUTTON1))
                Response = 1;
                [Failed ErrorMessage] = SendTrigger(EVENT.Button1,secs);
            elseif sum(keyCode(BUTTON2))
                Response = 2;
                [Failed ErrorMessage] = SendTrigger(EVENT.Button2,secs);
            elseif sum(keyCode(BUTTON3))
                Response = 3;
                [Failed ErrorMessage] = SendTrigger(EVENT.Button3,secs);
            elseif sum(keyCode(ABORT))
                Response = -1;
                Failed = 1;
                ExitStudy('Experiment aborted by user (in PracticeSlide)...');
                return
            end
            if Failed
                ExitStudy(ErrorMessage);
                Failed=1;
                return
            end
            % if a response was made, send a trigger
            if Response
                % write to log
                fprintf(LOGID,'%d\t%d\t%10.4f\tPracticeResponse[%g]\t%d\n',CURRENT_RUN,CURRENT_BLOCK,secs,Response,1);
                % reset box colors
                CurrentColor = BOXES_COLOR;
                % color new current box
                CurrentColor(:,Response+BOXES) = RESPONSE_CURRENT_COLOR;
                Screen('FillRect', WINDOW, CurrentColor, PracticeBoxes);
                Screen('Flip', WINDOW, secs + IFI, 1);
            end % if Response
        end % if keyIsDown
    end % while 
    if sum(keyCode(ABORT))
        Failed=1;
        ExitStudy('Study aborted by user...');
        return
    end
    if sum(keyCode(KbName('s')))
        FinishedAt = GetSecs;
        return 
    end
    keyCode(ADVANCE) = 0;
    % close textures
    Screen('Close', Texture);
    % Flip screen to reset drawing
    Screen('Flip', WINDOW);
    
    CueVBL = GetSecs;
    
    % ===
    % Show practice scenes
    % ===
    PracticeScenes = {'Laptop', 'Lego', 'Phone'};
    
    
    %===
    % Show practice anchors
    %===
    % get Anchors
    Questions={'How good or bad was the OUTCOME of this action?'
        'How good or bad was the MOTIVE of the person who did this?'
        'What was the LOCATION of the action?'};
    Anchors1={'Good', 'Neither', 'Bad'}; Anchors1=Anchors1(ANCHOR_ORDER);
	Anchors2={'Good', 'Neither', 'Bad'}; Anchors2=Anchors2(ANCHOR_ORDER);
	Anchors3={'Outside', 'Unsure', 'Inside'}; Anchors3=Anchors3(ANCHOR_ORDER);
    Anchors = {Anchors1{:} Anchors2{:} Anchors3{:}};
    
    Cues={'Outcome','Motive','Location'};
    
    % Draw response bar
    for r=1:3
        % show images
        
        try
            % draw Cue
            DrawFormattedText(WINDOW, Cues{r}, 'center', 'center', COLOR);
            CueVBL = Screen('Flip',WINDOW,CueVBL+IFI);


            [keyIsDown secs keyCode] = KbCheck(-3);
            keyCode(ADVANCE) = 0;
            keyCode(ABORT) = 0;
            while ~(sum(keyCode(ADVANCE)) || sum(keyCode(ABORT)));
                WaitSecs(.05);
                [keyIsDown secs keyCode ] = KbCheck(-3);
            end
            if sum(keyCode(ABORT))
                ExitStudy('Study aborted by users...');
                Failed=1;
                return
            end
            
            keyIsDown = 0;
            keyCode(ADVANCE) = 0;
            % ===
            % Load the 3 stimulus images
            % ===
            TrialName = ['training_bmps',filesep,PracticeScenes{r}];
            % get three image names
            TrialName1 = [TrialName,'_001.bmp'];
            TrialName2 = [TrialName,'_002.bmp'];
            TrialName3 = [TrialName,'_003.bmp'];

            if DEBUG
                fprintf('Loading images... at %10.4f\n', cputime);
            else
                % load the textures
                Picture1 = imread(TrialName1, 'bmp');
                Texture1 = Screen('MakeTexture', WINDOW, Picture1);

                Picture2 = imread(TrialName2, 'bmp');
                Texture2 = Screen('MakeTexture', WINDOW, Picture2);

                Picture3 = imread(TrialName3, 'bmp');
                Texture3 = Screen('MakeTexture', WINDOW, Picture3);
            end

            % draw texture1
            % =============
            if DEBUG
                fprintf('[PracticeSlide] Drawing Texture1:%s...\n', TrialName1);
                fprintf('[PracticeSlide] Flipping WINDOW...\n');
                StimVBLTime1 = cputime;
            else
                Screen('DrawTexture', WINDOW, Texture1);
                Screen('DrawingFinished', WINDOW);
                % display the image1
                StimVBLTime1 = Screen('Flip', WINDOW, secs + CUE_DURATION + IFI);
            end


            % write out info to log file
            fprintf(LOGID,'%d\t%d\t%10.4f\t%s\t%d\n',CURRENT_RUN,CURRENT_BLOCK,StimVBLTime1,TrialName1,NUM_TRIALS);


            % draw texture2
            % =============
            if DEBUG
                fprintf('[PracticeSlide] Drawing Texture2:%s...\n', TrialName2);
                fprintf('[PracticeSlide] Flipping WINDOW...\n');
                pause(PIC1_DURATION);
                StimVBLTime2 = cputime;
            else
                Screen('DrawTexture', WINDOW, Texture2);
                Screen('DrawingFinished', WINDOW);
                % display the image2
                StimVBLTime2 = Screen('Flip', WINDOW, StimVBLTime1 + PIC1_DURATION + IFI);
            end

            % write out info to log file
            fprintf(LOGID,'%d\t%d\t%10.4f\t%s\t%d\n', CURRENT_RUN, CURRENT_BLOCK, StimVBLTime2, TrialName2, NUM_TRIALS);

            % draw texture3
            % =============
            if DEBUG
                fprintf('[PracticeSlide] Drawing Texture3:%s...\n', cputime, TrialName3);
                fprintf('[PracticeSlide] Flipping WINDOW...\n');
                pause(PIC2_DURATION);
                StimVBLTime3 = cputime;
            else
                Screen('DrawTexture', WINDOW, Texture3);
                Screen('DrawingFinished', WINDOW);
                % display the image3
                StimVBLTime3 = Screen('Flip', WINDOW, StimVBLTime2 + PIC2_DURATION + IFI);
            end

            % write out info to log file
            fprintf(LOGID,'%d\t%d\t%10.4f\t%s\t%d\n', CURRENT_RUN, CURRENT_BLOCK, StimVBLTime3, TrialName3, NUM_TRIALS);
        catch ME
            Error = ME.stack(length(ME.stack)-1);
            ErrorInfo = sprintf('[%s|%d]',Error.name, Error.line);
            ExitStudy(sprintf('Problem creating/displaying images\n%s',strcat(ErrorInfo,ME.message)));
            success = 0;
            return
        end

        % "Washout" (not really a washout because it is short)
        % =========
        try
            if DEBUG
                fprintf('[PracticeSlide] "washout" +\n')
                WashoutVBL = cputime;
                pause(PIC3_DURATION);
            else
                DrawFormattedText(WINDOW, '+', 'center', 'center', COLOR);
                Screen('DrawingFinished', WINDOW);
                WashoutVBL = Screen('Flip', WINDOW, StimVBLTime3 + PIC3_DURATION + IFI);
                % write out info to log file
            end
            fprintf(LOGID,'%d\t%d\t%10.4f\t%s\t%d\n', CURRENT_RUN, CURRENT_BLOCK, WashoutVBL, 'PracticeWashoutOnset', NUM_TRIALS);

            [Failed ErrorMessage] = SendTrigger(EVENT.Off, WashoutVBL);
            if Failed
                ExitStudy(ErrorMessage);
                success=0;
                return
            end
        catch ME
            ExitStudy(ME.message);
            success=0;
            return
        end
        
        Screen('Close', Texture1);
        Screen('Close', Texture2);
        Screen('Close', Texture3);
        
        
        % store the BOXES_COLOR in local CurrentColor
        CurrentColor = BOXES_COLOR;
        % Draw response area without overwriting the current screen
        Screen('FillRect', WINDOW, CurrentColor, BOXES_RECT);

        % Response holds subject's response
        Response=0;
        
        DrawFormattedText(WINDOW, Questions{r}, 'center', 181, COLOR);
        % draw the anchors
        DrawFormattedText(WINDOW, Anchors{(r-1)*3+1}, 200, 'center', COLOR);
        DrawFormattedText(WINDOW, Anchors{(r-1)*3+2}, 'center', 'center', COLOR);
        % prep Anchor3 for drawing
        DrawFormattedText(WINDOW, Anchors{(r-1)*3+3}, (WINDOW_RECT(3) - 220 - length(Anchors{(r-1)*3+3})*10), 'center', COLOR);
        
         % display the response area
        ResponseVBL = Screen('Flip', WINDOW, WashoutVBL + WASHOUT_DURATION + IFI,1);
        % write to log
        fprintf(LOGID,'%d\t%d\t%10.4f\tDrawPracticeResponse\t%d\n', CURRENT_RUN, CURRENT_BLOCK, ResponseVBL, 1);
        
        while ~(sum(keyCode(ADVANCE)) || sum(keyCode(ABORT)))
        % listen for keyboard responses ADVANCE or ABORT
            WaitSecs(.05);
            [keyIsDown secs keyCode ] = KbCheck(-3);
            % check if key was pressed
            if keyIsDown
                keyPressed = KbName(find(keyCode));
                % check BUTTON1 mappings
                if sum(keyCode(BUTTON1))
                    Response = 1;
                elseif sum(keyCode(BUTTON2))
                    Response = 2;
                elseif sum(keyCode(BUTTON3))
                    Response = 3;
                elseif sum(keyCode(ABORT))
                    Response = -1;
                    ExitStudy('Experiment aborted by user (in PracticeSlide)...');
                    Failed = 1;
                    return
                end
                % if a response was made, send a trigger
                if Response
                    switch r
                        case 1
                            [Failed ErrorMessage] = SendTrigger(ANCHOR_VALUES{Response},secs);
                        case 2
                            % add 3 to Response to get to Motive indices
                            [Failed ErrorMessage] = SendTrigger(ANCHOR_VALUES{Response+3},secs);
                            % add 6 to Response to get to Location indices
                        case 3
                            [Failed ErrorMessage] = SendTrigger(ANCHOR_VALUES{Response+6},secs);
                    end
                    if Failed
                        ExitStudy(ErrorMessage);
                        success=0;
                        return
                    end
                    % write to log
                    fprintf(LOGID,'%d\t%d\t%10.4f\tTrialResponse([%g]\t%d\n',CURRENT_RUN,CURRENT_BLOCK,secs,Response,1);
                    % reset box colors
                    CurrentColor = BOXES_COLOR;
                    % color new current box
                    CurrentColor(:,Response+BOXES) = RESPONSE_CURRENT_COLOR;
                    Screen('FillRect', WINDOW, CurrentColor, BOXES_RECT, 1);
                    Screen('Flip', WINDOW, secs + IFI, 1);
                end % if Response
            end % if keyIsDown
        end % while not ABORT or ADVANCE
        if sum(keyCode(ABORT))
            Failed=1;
            ExitStudy('Study aborted by user...');
        end
        keyCode(ADVANCE) = 0;
        keyCode(ABORT) = 0;
        Screen('Flip',WINDOW);
        WaitSecs(0.05);
        
    end % for r=1:3
    
    % wait to make sure 'q' doesn't carry over
    WaitSecs(1);
    
    DrawFormattedText(WINDOW, 'Practice: Full speed', 'center', 'center', COLOR);
    CueVBL = Screen('Flip',WINDOW,GetSecs+IFI);

    keyCode(ADVANCE) = 0;
    keyCode(ABORT) = 0;
    [~, secs keyCode] = KbCheck(-3);

    while ~(sum(keyCode(ADVANCE)) || sum(keyCode(ABORT)));
        WaitSecs(.05);
        [~, secs keyCode ] = KbCheck(-3);
    end
    if sum(keyCode(ABORT))
        Failed = 1;
        ExitStudy('Study aborted by users...');
        return
    end
    
    % Draw response bar again
    for r=1:3
        % show images
        
        try
            % draw Cue
            DrawFormattedText(WINDOW, Cues{r}, 'center', 'center', COLOR);
            CueVBL = Screen('Flip',WINDOW,CueVBL+IFI);

            keyCode(ADVANCE) = 0;
            keyCode(ABORT) = 0;
            
            % ===
            % Load the 3 stimulus images
            % ===
            TrialName = ['training_bmps',filesep,PracticeScenes{r}];
            % get three image names
            TrialName1 = [TrialName,'_001.bmp'];
            TrialName2 = [TrialName,'_002.bmp'];
            TrialName3 = [TrialName,'_003.bmp'];

            if DEBUG
                fprintf('Loading images... at %10.4f\n', cputime);
            else
                % load the textures
                Picture1 = imread(TrialName1, 'bmp');
                Texture1 = Screen('MakeTexture', WINDOW, Picture1);

                Picture2 = imread(TrialName2, 'bmp');
                Texture2 = Screen('MakeTexture', WINDOW, Picture2);

                Picture3 = imread(TrialName3, 'bmp');
                Texture3 = Screen('MakeTexture', WINDOW, Picture3);
            end

            % draw texture1
            % =============
            if DEBUG
                fprintf('[PracticeSlide] Drawing Texture1:%s...\n', TrialName1);
                fprintf('[PracticeSlide] Flipping WINDOW...\n');
                StimVBLTime1 = cputime;
            else
                Screen('DrawTexture', WINDOW, Texture1);
                Screen('DrawingFinished', WINDOW);
                % display the image1
                StimVBLTime1 = Screen('Flip', WINDOW, CueVBL + CUE_DURATION + IFI);
            end


            % write out info to log file
            fprintf(LOGID,'%d\t%d\t%10.4f\t%s\t%d\n',CURRENT_RUN,CURRENT_BLOCK,StimVBLTime1,TrialName1,NUM_TRIALS);


            % draw texture2
            % =============
            if DEBUG
                fprintf('[PracticeSlide] Drawing Texture2:%s...\n', TrialName2);
                fprintf('[PracticeSlide] Flipping WINDOW...\n');
                pause(PIC1_DURATION);
                StimVBLTime2 = cputime;
            else
                Screen('DrawTexture', WINDOW, Texture2);
                Screen('DrawingFinished', WINDOW);
                % display the image2
                StimVBLTime2 = Screen('Flip', WINDOW, StimVBLTime1 + PIC1_DURATION + IFI);
            end

            % write out info to log file
            fprintf(LOGID,'%d\t%d\t%10.4f\t%s\t%d\n', CURRENT_RUN, CURRENT_BLOCK, StimVBLTime2, TrialName2, NUM_TRIALS);

            % draw texture3
            % =============
            if DEBUG
                fprintf('[PracticeSlide] Drawing Texture3:%s...\n', cputime, TrialName3);
                fprintf('[PracticeSlide] Flipping WINDOW...\n');
                pause(PIC2_DURATION);
                StimVBLTime3 = cputime;
            else
                Screen('DrawTexture', WINDOW, Texture3);
                Screen('DrawingFinished', WINDOW);
                % display the image3
                StimVBLTime3 = Screen('Flip', WINDOW, StimVBLTime2 + PIC2_DURATION + IFI);
            end

            % write out info to log file
            fprintf(LOGID,'%d\t%d\t%10.4f\t%s\t%d\n', CURRENT_RUN, CURRENT_BLOCK, StimVBLTime3, TrialName3, NUM_TRIALS);
        catch ME
            Error = ME.stack(length(ME.stack)-1);
            ErrorInfo = sprintf('[%s|%d]',Error.name, Error.line);
            ExitStudy(sprintf('Problem creating/displaying images\n%s',strcat(ErrorInfo,ME.message)));
            success = 0;
            return
        end

        % "Washout" (not really a washout because it is short)
        % =========
        try
            if DEBUG
                fprintf('[PracticeSlide] "washout" +\n')
                WashoutVBL = cputime;
                pause(PIC3_DURATION);
            else
                DrawFormattedText(WINDOW, '+', 'center', 'center', COLOR);
                Screen('DrawingFinished', WINDOW);
                WashoutVBL = Screen('Flip', WINDOW, StimVBLTime3 + PIC3_DURATION + IFI);
                % write out info to log file
            end
            fprintf(LOGID,'%d\t%d\t%10.4f\t%s\t%d\n', CURRENT_RUN, CURRENT_BLOCK, WashoutVBL, 'PracticeWashoutOnset', NUM_TRIALS);

            [Failed ErrorMessage] = SendTrigger(EVENT.Off, WashoutVBL);
            if Failed
                ExitStudy(ErrorMessage);
                success=0;
                return
            end
        catch ME
            ExitStudy(ME.message);
            success=0;
            return
        end
        
        Screen('Close', Texture1);
        Screen('Close', Texture2);
        Screen('Close', Texture3);
        

        % write to log
        fprintf(LOGID,'%d\t%d\t%10.4f\tDrawPracticeResponse\t%d\n', CURRENT_RUN, CURRENT_BLOCK, ResponseVBL, 1);

        % "Washout" (not really a washout because it is short)
        % =========
        try
            if DEBUG
                fprintf('[PracticeSlide] "washout" +\n')
                WashoutVBL = cputime;
                pause(PIC3_DURATION);
            else
                DrawFormattedText(WINDOW, '+', 'center', 'center', COLOR);
                Screen('DrawingFinished', WINDOW);
                WashoutVBL = Screen('Flip', WINDOW, WashoutVBL + WASHOUT_DURATION + IFI);
                % write out info to log file
            end
            fprintf(LOGID,'%d\t%d\t%10.4f\t%s\t%d\n', CURRENT_RUN, CURRENT_BLOCK, WashoutVBL, 'WashoutOnset', NUM_TRIALS);

            [Failed ErrorMessage] = SendTrigger(EVENT.Off, WashoutVBL);
            if Failed
                ExitStudy(ErrorMessage);
                success=0;
                return
            end
        catch ME
            ExitStudy(ME.message);
            success=0;
            return
        end
        
        
        % Response holds subject's response
        Response=0;
        
        DrawFormattedText(WINDOW, Questions{r}, 'center', 181, COLOR);
        % draw the anchors
        DrawFormattedText(WINDOW, Anchors{(r-1)*3+1}, 200, 'center', COLOR);
        DrawFormattedText(WINDOW, Anchors{(r-1)*3+2}, 'center', 'center', COLOR);
        % prep Anchor3 for drawing
        DrawFormattedText(WINDOW, Anchors{(r-1)*3+3}, (WINDOW_RECT(3) - 220 - length(Anchors{(r-1)*3+3})*10), 'center', COLOR);
        
         % display the response area
        % store the BOXES_COLOR in local CurrentColor
        CurrentColor = BOXES_COLOR;
        % Draw response area without overwriting the current screen
        Screen('FillRect', WINDOW, CurrentColor, BOXES_RECT);
        ResponseVBLTime  = Screen('Flip', WINDOW, WashoutVBL + WASHOUT_DURATION + IFI,1);
        ResponseStart = ResponseVBLTime;
        while GetSecs - ResponseStart < RESP_DURATION && ~(sum(keyCode(ADVANCE)) || sum(keyCode(ABORT)))
        % listen for keyboard responses ADVANCE or ABORT
            WaitSecs(.05);
            [keyIsDown secs keyCode ] = KbCheck(-3);
            % check if key was pressed
            if keyIsDown
                keyPressed = KbName(find(keyCode));
                % check BUTTON1 mappings
                if sum(keyCode(BUTTON1))
                    Response = 1;
                elseif sum(keyCode(BUTTON2))
                    Response = 2;
                elseif sum(keyCode(BUTTON3))
                    Response = 3;
                elseif sum(keyCode(ABORT))
                    Response = -1;
                    ExitStudy('Experiment aborted by user (in PracticeSlide)...');
                    Failed = 1;
                    return
                end
                % if a response was made, send a trigger
                if Response
                    switch r
                        case 1
                            [Failed ErrorMessage] = SendTrigger(ANCHOR_VALUES{Response},secs);
                        case 2
                            % add 3 to Response to get to Motive indices
                            [Failed ErrorMessage] = SendTrigger(ANCHOR_VALUES{Response+3},secs);
                            % add 6 to Response to get to Location indices
                        case 3
                            [Failed ErrorMessage] = SendTrigger(ANCHOR_VALUES{Response+6},secs);
                    end
                    if Failed
                        ExitStudy(ErrorMessage);
                        success=0;
                        return
                    end
                    % write to log
                    fprintf(LOGID,'%d\t%d\t%10.4f\tTrialResponse([%g]\t%d\n',CURRENT_RUN,CURRENT_BLOCK,secs,Response,1);
                    % reset box colors
                    CurrentColor = BOXES_COLOR;
                    % color new current box
                    CurrentColor(:,Response+BOXES) = RESPONSE_CURRENT_COLOR;
                    Screen('FillRect', WINDOW, CurrentColor, BOXES_RECT, 1);
                    ResponseVBL = Screen('Flip', WINDOW, secs + IFI, 1);
                end % if Response
            end % if keyIsDown
        end % while not ABORT or ADVANCE
        if sum(keyCode(ABORT))
            Failed=1;
            ExitStudy('Study aborted by user...');
        end
        keyCode(ADVANCE) = 0;
        keyCode(ABORT) = 0;
        Screen('Flip',WINDOW);
        WaitSecs(0.05);
        ResponseOff = GetSecs;
         % "ISI"
        % =========
        try
            if DEBUG
                fprintf('[PracticeSlide] ISI...\n');
                pause(ISI);
                ISIVBL = cputime;
            else
                DrawFormattedText(WINDOW, '+', 'center', 'center', COLOR);
                Screen('DrawingFinished', WINDOW);
                ISIVBL = Screen('Flip', WINDOW, ResponseOff + IFI);
            end
            % send Trigger
            [Failed ErrorMessage] = SendTrigger(EVENT.Off,ISIVBL);
            if Failed; ExitStudy(ErrorMessage); success=0; return; end;
            WaitSecs(ISI_current(r));
            % write out info to log file
            fprintf(LOGID,'%d\t%d\t%10.4f\t%s\t%d\n', CURRENT_RUN, CURRENT_BLOCK, ISIVBL, 'ISIOnset', NUM_TRIALS);
            fprintf(LOGID,'%d\t%d\t%10.4f\tISI[%g]\t%d\n',CURRENT_RUN,CURRENT_BLOCK,ISIVBL,ISI_current(r),NUM_TRIALS);
        catch ME
            ExitStudy(ME.message);
            success=0;
            return
        end

    end % for r=1:3
    
    
    FinishedAt = GetSecs;
    Screen('Flip',WINDOW);
    
catch ME
    Failed=1;
    ExitStudy(ME.message);
    return
end % end try

%{
% draw the question
    DrawFormattedText(WINDOW, Question, 'center', 181, COLOR);
    % draw the anchors
    DrawFormattedText(WINDOW, Anchors{1}, 100, 'center', COLOR);
    DrawFormattedText(WINDOW, Anchors{2}, 'center', 'center', COLOR);
    % prep Anchor3 for drawing
    DrawFormattedText(WINDOW, Anchors{3}, (WINDOW_RECT(3) - 100 - length(Anchors{3})*10), 'center', COLOR);
    
    
    % Draw response bar
            KeyPresses=[];
            KeyPressTimes=[];
            % store the BOXES_COLOR in local CurrentColor
            CurrentColor = BOXES_COLOR;
            % Draw response area without overwriting the current screen
            Screen('FillRect', WINDOW, CurrentColor, BOXES_RECT);
            % display the response area
            [ResponseVBLTime ResponseOnsetTime] = Screen('Flip', WINDOW, WashoutOnset + WASHOUT_DURATION + IFI,1);
        end
        % send trigger
        switch Cue
            case 'Outcome'
                [Failed ErrorMessage] = SendTrigger(EVENT.OutcomeResponseStart,ResponseVBLTime);
            case 'Motive'
                [Failed ErrorMessage] = SendTrigger(EVENT.MotiveResponseStart,ResponseVBLTime);
            case 'Location'
                [Failed ErrorMessage] = SendTrigger(EVENT.LocationResponseStart,ResponseVBLTime);
        end
        if Failed
            ExitStudy(ErrorMessage);
            success=0;
            return
        end
        % write to log
        fprintf(LOGID,'%d\t%d\t%10.4f\tDrawResponse\t%d\n', CURRENT_RUN, CURRENT_BLOCK, ResponseOnsetTime, NUM_TRIALS);
 
        % Response holds subject's response
        Response=0;
        
        if DEBUG
            fprintf('[PracticeSlide] Getting response...\n');
            pause(RESP_DURATION);
        else
            while GetSecs - ResponseOnsetTime < RESP_DURATION
            % listen for keyboard responses until RESP_DURATION
                WaitSecs(.05);
                [keyIsDown secs keyCode ] = KbCheck(-3);
                % check if key was pressed
                if keyIsDown
                    keyPressed = KbName(find(keyCode));
                    % check BUTTON1 mappings
                    if sum(keyCode(BUTTON1))
                        Response = 1;
                    elseif sum(keyCode(BUTTON2))
                        Response = 2;
                    elseif sum(keyCode(BUTTON3))
                        Response = 3;
                    elseif sum(keyCode(ABORT))
                        Response = -1;
                        ExitStudy('Experiment aborted by user (in PracticeSlide)...');
                        success = 0;
                        return
                    end
                    % if a response was made, send a trigger
                    if Response
                        switch Cue
                            case 'Outcome'
                                [Failed ErrorMessage] = SendTrigger(ANCHOR_VALUES{Response},ResponseOnsetTime);
                            case 'Motive'
                                % add 3 to Response to get to Motive indices
                                [Failed ErrorMessage] = SendTrigger(ANCHOR_VALUES{Response+3},ResponseOnsetTime);
                                % add 6 to Response to get to Location indices
                            case 'Location'
                                [Failed ErrorMessage] = SendTrigger(ANCHOR_VALUES{Response+6},ResponseOnsetTime);
                        end
                        if Failed
                            ExitStudy(ErrorMessage);
                            success=0;
                            return
                        end
                        % write to log
                        fprintf(LOGID,'%d\t%d\t%10.4f\tTrialResponse([%d]\t%d\n',CURRENT_RUN,CURRENT_BLOCK,secs,Response,NUM_TRIALS);
                        % reset box colors
                        CurrentColor = BOXES_COLOR;
                        % color new current box
                        CurrentColor(:,Response+BOXES) = RESPONSE_CURRENT_COLOR;
                        Screen('FillRect', WINDOW, CurrentColor, BOXES_RECT);
                        [vbl ResponseOnsetTime] = Screen('Flip', WINDOW, ResponseOnsetTime + IFI, 1);
                    end % if Response
                end % if keyIsDown
            end % while time < RESP_DURATION
%}