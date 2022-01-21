function opt = get_option_preprocess()
  %
  % returns options chosen to run pre-processing
  %
  % opt = get_option_preprocess()
  %
  % (C) Copyright 2019 CPP_SPM developers

  if nargin < 1
    opt = [];
  end

  % task to analyze
  opt.taskName = 'visMotion';
  opt.pipeline.type = 'preproc';

  this_dir = fileparts(mfilename('fullpath'));
  root_dir = fullfile(this_dir, '..', '..', '..', '..');
  opt.dir.raw = fullfile(root_dir, 'inputs', 'raw');
  opt.dir.derivatives = fullfile(root_dir, 'outputs', 'derivatives');

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
