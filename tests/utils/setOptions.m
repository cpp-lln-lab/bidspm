function opt = setOptions(task, subLabel)
  %
  % (C) Copyright 2021 CPP_SPM developers

  thisDir = fileparts(mfilename('fullpath'));

  opt = setTestCfg();

  opt.dir = [];

  if strcmp(task, 'MoAE')

    opt.dir.raw = fullfile(thisDir, ...
                           '..', '..', 'demos',  'MoAE', 'inputs', 'raw');
    opt.model.file = fullfile(thisDir, ...
                              '..', '..', 'demos',  'MoAE', 'models', 'model-MoAE_smdl.json');

    opt.taskName = 'auditory';

    opt.result.Steps.Contrasts(1).Name = 'listening';
    opt.result.Steps.Contrasts(2).Name = 'listening_inf_baseline';

  elseif strcmp(task, 'MoAE-preproc')

    opt.dir.derivatives = spm_file(fullfile(thisDir, '..', 'dummyData', 'MoAE', 'derivatives'), ...
                                   'cpath');
    opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');
    opt.dir.stats = fullfile(opt.dir.derivatives, 'cpp_spm-stats');

    opt.model.file = fullfile(thisDir, ...
                              '..', '..', 'demos',  'MoAE', 'models', 'model-MoAE_smdl.json');

    opt.taskName = 'auditory';

    opt.result.Steps.Contrasts(1).Name = 'listening';
    opt.result.Steps.Contrasts(2).Name = 'listening_inf_baseline';

  elseif strcmp(task, 'fmriprep')

    opt.taskName = 'rest';
    opt.dir.derivatives = spm_file(fullfile(thisDir, '..', 'dummyData', 'derivatives'), 'cpath');
    opt.pipeline.name = 'fmriprep';

  else

    opt.taskName = task;
    opt.dir.derivatives = spm_file(fullfile(thisDir, '..', 'dummyData', 'derivatives'), 'cpath');
    opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');
    opt.dir.stats = fullfile(opt.dir.derivatives, 'cpp_spm-stats');
    opt.model.file = fullfile(thisDir, '..', 'dummyData',  'models', ...
                              ['model-' task '_smdl.json']);

  end

  opt = checkOptions(opt);

  if nargin > 1
    opt.subjects = {subLabel};
  end

end
