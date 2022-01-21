function opt = get_option_stats()
  %
  % returns options chosen to run statistical analysis
  %
  % opt = get_option_preprocess()
  %
  % (C) Copyright 2019 CPP_SPM developers

  if nargin < 1
    opt = [];
  end

  % task to analyze
  opt.taskName = 'visMotion';
  opt.pipeline.type = 'stats';

  % The directory where the data are located
  % assumes the following set up

  % ├── code
  % │   └── CPP_SPM
  % │       ├── demos
  % │       │   └── vismotion
  % │       │       └── models
  % |       ...
  % │       ├── docs
  % │       ├── src
  % │       └── tests
  % ├── inputs
  % │   └── raw
  % │       ├── sub-con07
  % │       ├── sub-con08
  % │       └── sub-con15
  % └── outputs
  %     └── cpp_spm-preproc
  %         ├── sub-con07
  %         ├── sub-con08
  %         └── sub-con15

  this_dir = fileparts(mfilename('fullpath'));
  root_dir = fullfile(this_dir, '..', '..', '..');
  opt.dir.raw = fullfile(root_dir, inputs', 'raw');
  opt.dir.preproc = fullfile(root_dir, 'outputs', 'derivatives', 'cpp_spm-preproc');
  opt.dir.stats = fullfile(root_dir, 'outputs', 'derivatives', 'cpp_spm-stats');

  % specify the model file that contains the contrasts to compute
  opt.model.file = fullfile(this_dir, 'models', 'model-visMotionLoc_smdl.json');

  % specify the result to compute
  % Contrasts.Name has to match one of the contrast defined in the model json file
  opt.result.Nodes(1) = struct( ...
                               'Level',  'dataset', ...
                               'Contrasts', struct( ...
                                                   'Name', 'VisMot_gt_VisStat', ... %
                                                   'Mask', false, ...
                                                   'MC', 'FWE', ... FWE, none, FDR
                                                   'p', 0.05, ...
                                                   'k', 0, ...
                                                   'NIDM', true));

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
