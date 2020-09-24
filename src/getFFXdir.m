% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function ffxDir = getFFXdir(subID, funcFWFM, opt, isMVPA)
    % ffxDir = getFFXdir(subID, funcFWFM, opt, isMVPA)
    %
    % sets the name the FFX directory and creates it if it does not exist
    %
    %

    mvpaSuffix = setMvpaSuffix(isMVPA);

    ffxDir = fullfile(opt.dataDir, '..', 'derivatives', 'SPM12_CPPL', ...
                      ['sub-', subID], ...
                      'stats', ...
                      ['ffx_task-', opt.taskName], ...
                      ['ffx_FWHM-', num2str(funcFWFM), mvpaSuffix]);

    if ~exist(ffxDir, 'dir')
        mkdir(ffxDir);
    end
end
