% Testing KbCheck timing and usage
function TestKbCheck
Priority(1);
% get the standard keyboard mappings
KbName('UnifyKeyNames');
% turn off keyboard output to MATLAB command window
ListenChar(2);

% TEST 1: Display the keys pressed until ESCAPE is pressed
EndCode = KbName('ESCAPE');
[keyIsDown secs keyCode ] = KbCheck;
fprintf('Press any key...\n');

while (keyCode(EndCode) ~= 1)
    [keyIsDown secs keyCode ] = KbCheck;
    % check if key was pressed
    if keyIsDown
        keyPressed = KbName(find(keyCode));
        fprintf('You pressed: ');
        disp(keyPressed)
        
        if keyCode(KbName('LeftArrow')) == 1
            disp('You pushed Left Arrow!')
        end
    end
    % don't overload the system with Kb pulls
    WaitSecs(0.001);
end

ListenChar(0);

Priority(0);
