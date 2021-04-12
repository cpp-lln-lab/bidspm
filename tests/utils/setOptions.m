% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

function opt = setOptions(task, subLabel)

  thisDir = fileparts(mfilename('fullpath'));

  opt.dir = [];

  if strcmp(task, 'MoAE')

    opt.dataDir = fullfile(thisDir, ...
                           '..', '..', 'demos',  'MoAE', 'inputs', 'raw');
    opt.model.file = fullfile(thisDir, ...
                              '..', '..', 'demos',  'MoAE', 'models', 'model-MoAE_smdl.json');

    opt.taskName = 'auditory';

  else

    opt.taskName = task;
    opt.derivativesDir = fullfile(thisDir, '..', 'dummyData');
    opt.model.file = fullfile(opt.derivativesDir,  'models', ...
                              ['model-' task '_smdl.json']);

  end

  opt = checkOptions(opt);

  if nargin > 1
    opt.subjects = {subLabel};
  end

end
