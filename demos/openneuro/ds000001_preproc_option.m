function opt = ds000001_preproc_option()
  %
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX.
  %
  % (C) Copyright 2020 CPP_SPM developers

  if nargin < 1
    opt = [];
  end

  % suject to run in each group
  opt.subjects = {'01', '02'};

  % task to analyze
  opt.taskName = 'balloonanalogrisktask';

  opt.pipeline.type = 'preproc';

  % The directory where the data are located
  root_dir = fileparts(mfilename('fullpath'));
  opt.dir.raw = fullfile(root_dir, 'inputs', 'ds000001');
  opt.dir.derivatives = fullfile(root_dir, 'outputs', 'ds000001', 'derivatives');

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
