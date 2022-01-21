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

  this_dir = fileparts(mfilename('fullpath'));
  root_dir = fullfile(this_dir, '..', '..', '..', '..');
  opt.dir.raw = fullfile(root_dir, 'inputs', 'raw');
  opt.dir.preproc = fullfile(root_dir, 'outputs', 'derivatives', 'cpp_spm-preproc');
  opt.dir.stats = fullfile(root_dir, 'outputs', 'derivatives', 'cpp_spm-stats');

  opt.space = 'IXI549Space';

  % don't specify a stats model will let cpp spm run and try to figure out a
  % default model
  % opt.model.file = '';

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
