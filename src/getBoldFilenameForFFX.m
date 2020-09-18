% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function [boldFileName, prefix] = getBoldFilenameForFFX(varargin)
    % [boldFileName, prefix] = getFunctionalFiles(BIDS, opt, subID, funcFWHM, iSes, iRun)
    %
    % get the filename for this bold run for this task for the FFX setup
    % and check that the file with the right prefix exist

    [BIDS, opt, subID, funcFWHM, iSes, iRun] =  deal(varargin{:});

    sessions = getInfo(BIDS, subID, opt, 'Sessions');

    runs = getInfo(BIDS, subID, opt, 'Runs', sessions{iSes});

    prefix = getPrefix('FFX', opt, funcFWHM);
    if strcmp(opt.space, 'T1w')
        prefix = getPrefix('FFX_space-T1w', opt, funcFWHM);
    end

    [fileName, subFuncDataDir] = getBoldFilename( ...
        BIDS, ...
        subID, sessions{iSes}, runs{iRun}, opt);

    boldFileName = inputFileValidation( ...
        subFuncDataDir, ...
        prefix, ...
        fileName);

    disp(boldFileName);

end
