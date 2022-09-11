function opt = getOption()
  %
  % returns a structure that contains the options chosen for preprocessing
  %
  %
  % (C) Copyright 2022 bidspm developers

  if nargin < 1
    opt = [];
  end

  % task to analyze
  opt.taskName = 'balloonanalogrisktask';

  % The directory where the data are located
  opt.dir.raw = FIXME;
  opt.dir.derivatives = FIXME;

  % Options for slice time correction
  % If left unspecified the slice timing will be done using the mid-volume acquisition
  % time point as reference.
  % opt.STC_referenceSlice = [];

  % when opt.ignoreFieldmaps is set to false, the
  % preprocessing pipeline will look for the voxel displacement maps (created by
  % the corresponding workflow) and will use them for realign and unwarp
  % opt.ignoreFieldmaps = false;

  % session number and type of the anatomical reference
  % opt.bidsFilterFiler.t1w.suffix = 'T1w';
  % opt.bidsFilterFiler.t1w.ses = 1;

  % any voxel with p(grayMatter) +  p(whiteMatter) + p(CSF) > threshold
  % will be included in the skull stripping mask
  % opt.skullstrip.threshold = 0.75;

  % space where we conduct the analysis
  % opt.space = 'IXI549Space';

  % Options for normalize
  % Voxel dimensions for resampling at normalization of functional data or leave empty [ ].
  % opt.funcVoxelDims = [];

end
