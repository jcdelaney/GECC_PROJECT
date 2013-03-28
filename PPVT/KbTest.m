function KbTest
ListenChar(2);
KbName('UnifyKeyNames');

KeepChecking = 1;
while KeepChecking
    pause(.01);
    [keyIsDown secs keyCode ] = KbCheck(-3);
    % check if key was pressed
    if keyIsDown
        keyPressed = KbName(find(keyCode));
        fprintf('You pressed: ');
        disp(keyPressed)
        if strcmp(keyPressed,'q')
            KeepChecking = 0;
        end
    end
end
ListenChar(0);