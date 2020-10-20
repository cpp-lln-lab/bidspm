% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function opt = ds000114_getOption()
    % returns a structure that contains the options chosen by the user to run
    % slice timing correction, pre-processing, FFX, RFX.

    if nargin < 1
        opt = [];
    end

    % suject to run in each group
    opt.subjects = {'01', '02'};

    % task to analyze
    opt.taskName = 'overtwordrepetition';

    % The directory where the data are located
    opt.dataDir = '/home/remi/openneuro/ds000114/raw';

    %% DO NOT TOUCH
    opt = checkOptions(opt);
    saveOptions(opt);

end
