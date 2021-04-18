function opt = setOptions(task, subLabel)
  %
  % (C) Copyright 2021 CPP_SPM developers

  thisDir = fileparts(mfilename('fullpath'));

  opt.dir = [];

  if strcmp(task, 'MoAE')

    opt.dir.raw = fullfile(thisDir, ...
                           '..', '..', 'demos',  'MoAE', 'inputs', 'raw');
    opt.dir.input = opt.dir.raw;
    opt.model.file = fullfile(thisDir, ...
                              '..', '..', 'demos',  'MoAE', 'models', 'model-MoAE_smdl.json');

    opt.taskName = 'auditory';

    opt.result.Steps.Contrasts(1).Name = 'listening';
    opt.result.Steps.Contrasts(2).Name = 'listening_inf_baseline';

  else

    opt.taskName = task;
    opt.dir.derivatives = fullfile(thisDir, '..', 'dummyData');
    opt.model.file = fullfile(opt.dir.derivatives,  'models', ...
                              ['model-' task '_smdl.json']);

  end

  opt = checkOptions(opt);

  if nargin > 1
    opt.subjects = {subLabel};
  end

end
