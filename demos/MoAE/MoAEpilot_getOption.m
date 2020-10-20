% (C) Copyright 2019 Remi Gau

function opt = MoAEpilot_getOption()
    % returns a structure that contains the options chosen by the user to run
    % slice timing correction, pre-processing, FFX, RFX.

    if nargin < 1
        opt = [];
    end

    % task to analyze
    opt.taskName = 'auditory';

    % The directory where the data are located
    opt.dataDir = fullfile(fileparts(mfilename('fullpath')), 'output', 'MoAEpilot');
    opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')));

    opt.model.univariate.file = fullfile(fileparts(mfilename('fullpath')), ...
                                         'models', 'model-MoAE_smdl.json');

    % specify the result to compute
    opt.result.Steps(1) = struct( ...
                                 'Level',  'subject', ...
                                 'Contrasts', struct( ...
                                                     'Name', 'listening', ... % has to match
                                                     'Mask', false, ...
                                                     'MC', 'FWE', ... FWE, none, FDR
                                                     'p', 0.05, ...
                                                     'k', 0, ...
                                                     'NIDM', true));

    opt.result.Steps(1).Contrasts(2) = struct( ...
                                              'Name', 'listening_inf_baseline', ...
                                              'Mask', false, ...
                                              'MC', 'none', ... FWE, none, FDR
                                              'p', 0.01, ...
                                              'k', 0, ...
                                              'NIDM', true);

    %% DO NOT TOUCH
    opt = checkOptions(opt);

end
