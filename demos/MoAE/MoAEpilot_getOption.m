% (C) Copyright 2019 Remi Gau

function opt = MoAEpilot_getOption()
    % returns a structure that contains the options chosen by the user to run
    % slice timing correction, pre-processing, FFX, RFX.

    if nargin < 1
        opt = [];
    end

    % group of subjects to analyze
    opt.groups = {''};
    % suject to run in each group
    opt.subjects = {[]};

    % task to analyze
    opt.taskName = 'auditory';

    % The directory where the data are located
    opt.dataDir = fullfile(fileparts(mfilename('fullpath')), 'output', 'MoAEpilot');
    opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')));

    % Options for slice time correction
    % If left unspecified the slice timing will be done using the mid-volume acquisition
    % time point as reference.
    % Slice order must be entered in time unit (ms) (this is the BIDS way of doing things)
    % instead of the slice index of the reference slice (the "SPM" way of doing things).
    % More info here: https://en.wikibooks.org/wiki/SPM/Slice_Timing
    opt.sliceOrder = [];
    opt.STC_referenceSlice = [];

    % Options for normalize
    % Voxel dimensions for resampling at normalization of functional data or leave empty [ ].
    opt.funcVoxelDims = [];

    % Suffix output directory for the saved jobs
    opt.jobsDir = fullfile(opt.dataDir, '..', 'derivatives', 'SPM12_CPPL', 'JOBS', opt.taskName);

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

end
