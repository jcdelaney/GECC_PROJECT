% class definition for event codes used in the ppvt study
classdef EEAEvents
    properties (Constant)
        % event codes for sending
        % {keyvalue, keycode}
        ExperimentStart = {0,'EXGO'};
        Off = {0,'NONE'};
        QPress = {1,'QHIT'};
        ScannerStart = {1,'SCGO'};
        RunEnd = {0,'REND'};
        BlockStart = {1,'BKGO'};
        ISI = {1,'ISIS'};
        MatchTrial = {2,'MTCH'};
        MismatchTrial = {2,'MISM'};
        AwarenessCheck = {2,'AWCK'};
        Success = {3,'PASS'};
        Failure = {4,'FAIL'};
        Miss = {5,'MISS'};
        AudioStart = {5,'ASTR'};
        AudioStop = {5,'AEND'};
        Pause = {5,'BRCK'};
        Button1 = {2,'BUT1'};
        Button2 = {2,'BUT2'};
        % rest
        RestBlockStart = {0, 'RBGO'};
    end
end

