function opt = templateGetOption()
  %
  % returns a structure that contains the options chosen by the user to return
  % the different workflows
  %
  % (C) Copyright 2020 CPP_SPM developers

  if nargin < 1
    opt = [];
  end

  % group of subjects to analyze
  % opt.groups = {''};
  % suject to run in each group
  % opt.subjects = {[]};

  % task to analyze
  opt.taskName = 'balloonanalogrisktask';

  % The directory where the data are located
  opt.dataDir = '/home/remi/BIDS/ds001/rawdata';

  % Where the data will go
  % opt.derivativesDir = '';

  % Options for slice time correction
  % If left unspecified the slice timing will be done using the mid-volume acquisition
  % time point as reference.
  % Slice order must be entered in time unit (ms) (this is the BIDS way of doing things)
  % instead of the slice index of the reference slice (the "SPM" way of doing things).
  % More info here: https://en.wikibooks.org/wiki/SPM/Slice_Timing
  % opt.sliceOrder = [];
  % opt.STC_referenceSlice = [];

  % when opt.ignoreFieldmaps is set to false, the
  % preprocessing pipeline will look for the voxel displacement maps (created by
  % the corresponding workflow) and will use them for realign and unwarp
  % opt.ignoreFieldmaps = false;

  % session number and type of the anatomical reference
  % opt.anatReference.type = 'T1w';
  % opt.anatReference.session = 1;

  % any voxel with p(grayMatter) +  p(whiteMatter) + p(CSF) > threshold
  % will be included in the skull stripping mask
  % opt.skullstrip.threshold = 0.75;

  % space where we conduct the analysis
  % opt.space = 'MNI';

  % Options for normalize
  % Voxel dimensions for resampling at normalization of functional data or leave empty [ ].
  % opt.funcVoxelDims = [];

  % specify the model file that contains the contrasts to compute
  opt.model.univariate.file =  ...
    fullfile(fileparts(mfilename('fullpath')), ...
             'model', ...
             'model - balloonanalogriskUnivariate_smdl.json');

  % specify the result to compute
  % opt.result.Steps(1) = struct( ...
  %                              'Level',  'dataset', ...
  %                              'Contrasts', struct( ...
  %                                                  'Name', 'pumps_demean', ...
  %                                                  'Mask', false, ...
  %                                                  'MC', 'none', ... FWE, none, FDR
  %                                                  'p', 0.05, ...
  %                                                  'k', 0, ...
  %                                                  'NIDM', true));

end
