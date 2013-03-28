% generate a full list of stimuli used for the study
function StimList = MakeStimList

here=pwd;

% read in the list of Good scenes
fid = fopen('GoodList.csv','r');
line = fgetl(fid);
StimList={};
% line is not EOF and next scene name has been added to GoodSceneList
while line ~= -1
    StimList{end+1} = [here,filesep,'bmps',filesep,'g_',line,'_001.bmp'];
    StimList{end+1} = [here,filesep,'bmps',filesep,'g_',line,'_002.bmp'];
    StimList{end+1} = [here,filesep,'bmps',filesep,'g_',line,'_003.bmp'];
    line = fgetl(fid);
end
fclose(fid);

% read in the list of Bad scenes
fid = fopen('BadList.csv','r');
line = fgetl(fid);
% line is not EOF and next scene name has been added to GoodSceneList
while line ~= -1
    StimList{end+1} = [here,filesep,'bmps',filesep,'b_',line,'_001.bmp'];
    StimList{end+1} = [here,filesep,'bmps',filesep,'b_',line,'_002.bmp'];
    StimList{end+1} = [here,filesep,'bmps',filesep,'b_',line,'_003.bmp'];
    line = fgetl(fid);
end
fclose(fid);

% read in the list of Neutral scenes
fid = fopen('NeutList.csv','r');
line = fgetl(fid);
% line is not EOF and next scene name has been added to GoodSceneList
while line ~= -1
    StimList{end+1} = [here,filesep,'bmps',filesep,'n_',line,'_001.bmp'];
    StimList{end+1} = [here,filesep,'bmps',filesep,'n_',line,'_002.bmp'];
    StimList{end+1} = [here,filesep,'bmps',filesep,'n_',line,'_003.bmp'];
    line = fgetl(fid);
end
fclose(fid);
