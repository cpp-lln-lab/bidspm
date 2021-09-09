function opt = moae_get_option_fmriprep_preproc()
  %
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX.
  %
  % (C) Copyright 2019 Remi Gau

  opt = [];

  % task to analyze
  opt.taskName = 'auditory';
  opt.verbosity = 1;

  % The directory where the data are located
  WD = fileparts(mfilename('fullpath'));
  opt.dir.raw = fullfile(WD, 'inputs', 'raw');
  opt.dir.input = fullfile(WD, 'spm_moae_fmriprep');
  opt.dir.derivatives = fullfile(WD, 'outputs', 'derivatives');

  opt.space = {'MNI152NLin2009cAsym'};

  opt.query.desc = {'preproc', 'confounds'};
  %   opt.query.space = opt.space;

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
