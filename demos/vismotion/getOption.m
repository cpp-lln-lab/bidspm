% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function opt = getOption()
    % opt = getOption()
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
    opt.taskName = 'visMotion';

    % The directory where the data are located
    opt.dataDir = '/home/remi/BIDS/visMotion/derivatives/';

    % specify the model file that contains the contrasts to compute
    opt.model.univariate.file = ...
        '/home/remi/github/CPP_BIDS_SPM_pipeline/model-visMotionLoc_smdl.json';
    opt.model.multivariate.file = '';

    % specify the result to compute
    % Contrasts.Name has to match one of the contrast defined in the model json file
    opt.result.Steps(1) = struct( ...
                                 'Level',  'dataset', ...
                                 'Contrasts', struct( ...
                                                     'Name', 'VisMot_gt_VisStat', ... %
                                                     'Mask', false, ...
                                                     'MC', 'FWE', ... FWE, none, FDR
                                                     'p', 0.05, ...
                                                     'k', 0, ...
                                                     'NIDM', true));

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

end
