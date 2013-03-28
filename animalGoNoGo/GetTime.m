% Returns the current time (HH:MM:SS) as a string
function timestr = GetTime

time = fix(clock);
timestr = sprintf('%d:%d:%2d',time([4 5 6]));