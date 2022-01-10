function opt = moae_get_option()
  %
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX.
  %
  % (C) Copyright 2019 Remi Gau

  opt = [];

  % task to analyze
  opt.pipeline.type = 'preproc';
  opt.taskName = {'auditory'};
  opt.verbosity = 1;

  % The directory where the data are located
  opt.dir.raw = fullfile(fileparts(mfilename('fullpath')), 'inputs', 'raw');
  opt.dir.derivatives = fullfile(opt.dir.raw, '..', '..', 'outputs', 'derivatives');

  % Uncomment the lines below to run preprocessing
  % - don't use realign and unwarp
  % opt.realign.useUnwarp = false;

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
