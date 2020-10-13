% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function reportBIDS(opt)

    bids.report(opt.dataDir);

    % TODO save output in the derivatires folder
    %     derivativeDir = fullfile(rawDir, '..', 'derivatives', 'SPM12_CPPL');

end
