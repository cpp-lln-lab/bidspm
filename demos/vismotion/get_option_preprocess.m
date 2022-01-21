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

  % The directory where the data are located
  % assumes the following set up

  % ├── code
  % │   └── CPP_SPM
  % │       ├── demos
  % │       │   └── vismotion
  % |       ...
  % │       ├── docs
  % │       ├── src
  % │       └── tests
  % └── inputs
  %     └── raw
  %         ├── sub-con07
  %         ├── sub-con08
  %         └── sub-con15

  this_dir = fileparts(mfilename('fullpath'));
  root_dir = fullfile(this_dir, '..', '..', '..', '..');
  opt.dir.raw = fullfile(root_dir, 'inputs', 'raw');
  opt.dir.derivatives = fullfile(root_dir, 'outputs', 'derivatives');

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
