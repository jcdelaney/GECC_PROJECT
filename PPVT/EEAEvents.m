% class definition for event codes used in the everyday_actions study
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
        % training codes
        TrainingStart = {2,'TRGO'};
        Button1 = {2,'BUT1'};
        Button2 = {2,'BUT2'};
        Button3 = {2,'BUT3'};
        TrainingEnd = {0,'TEND'};
        Washout = {0,'WASH'};
        % stim onset codes
        GoodPic1 = {3,'GPO1'};
        GoodPic2 = {4,'GPO2'};
        GoodPic3 = {5,'GPO3'};
        BadPic1 = {3,'BPO1'};
        BadPic2 = {4,'BPO2'};
        BadPic3 = {5,'BPO3'};
        NeutPic1 = {3,'NPO1'};
        NeutPic2 = {4,'NPO2'};
        NeutPic3 = {5,'NPO3'};
        % outcome
        OutcomeBlockStart = {6,'OBGO'};
        OutcomeResponseStart = {7,'ORGO'};
        OutcomeGoodResponse = {12,'OBGR'};
        OutcomeBadResponse = {13,'OBBR'};
        OutcomeNeutResponse = {14,'OBNR'};
        OutcomeMiss = {15,'OBMR'};
        % Motive
        MotiveBlockStart = {8,'IBGO'};
        MotiveResponseStart = {9,'IRGO'};
        MotiveGoodResponse = {12,'IBGR'};
        MotiveBadResponse = {13,'IBBR'};
        MotiveNeutResponse = {14,'IBNR'};
        MotiveMiss = {15,'IBMR'};
        % location
        LocationBlockStart = {10,'LBGO'};
        LocationResponseStart = {11,'LRGO'};
        LocationInsideResponse = {12,'LBIR'};
        LocationOutsideResponse = {13,'LBOR'};
        LocationUnsureResponse = {14,'LBUR'};
        LocationMiss = {15,'LBMR'};
        % rest
        RestBlockStart = {0, 'RBGO'};
    end
end

