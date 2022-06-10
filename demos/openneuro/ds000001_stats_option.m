function opt = ds000001_stats_option()
  %
  % returns a structure that contains the options chosen by the user to run
  % subject and group level analysis
  %
  % (C) Copyright 2020 CPP_SPM developers

  if nargin < 1
    opt = [];
  end

  % suject to run in each group
  opt.subjects = {'01', '02'};

  opt.pipeline.type = 'stats';

  opt.space = 'IXI549Space';

  % The directory where the data are located
  root_dir = fileparts(mfilename('fullpath'));
  opt.dir.raw = fullfile(root_dir, 'inputs', 'ds000001');
  opt.dir.derivatives = fullfile(root_dir, 'outputs', 'ds000001', 'derivatives');
  opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');

  opt.model.file = fullfile(root_dir, 'models', 'model-defaultBalloonanalogrisktask_smdl.json');

  opt.results.nodeName = 'subject_level';
  opt.results.name = 'cash_demean';
  opt.results.png = true();

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
