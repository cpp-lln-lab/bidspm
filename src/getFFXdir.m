% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function ffxDir = getFFXdir(subID, funcFWFM, opt)
    % ffxDir = getFFXdir(subID, funcFWFM, opt)
    %
    % sets the name the FFX directory and creates it if it does not exist
    %
    %

    ffxDir = fullfile(opt.derivativesDir, ...
                      ['sub-', subID], ...
                      'stats', ...
                      ['ffx_task-', opt.taskName], ...
                      ['ffx_space-' opt.space '_FWHM-', num2str(funcFWFM)]);

    if ~exist(ffxDir, 'dir')
        mkdir(ffxDir);
    end
end
