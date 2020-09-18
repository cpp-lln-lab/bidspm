% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function reportBIDS(opt)

    rawDir = opt.dataDir;

    bids.report(rawDir);

    derivativeDir = fullfile(rawDir, '..', 'derivatives', 'SPM12_CPPL');

    % make derivatives folder if it doesnt exist
    if ~exist(derivativeDir, 'dir')
        mkdir(derivativeDir);
        fprintf('derivatives directory created: %s \n', derivativeDir);
    else
        fprintf('derivatives directory already exists. \n');
    end

end
