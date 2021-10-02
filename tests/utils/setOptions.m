function opt = setOptions(task, subLabel, useRaw)
  %
  % (C) Copyright 2021 CPP_SPM developers

  opt = setTestCfg();

  if nargin > 1 && ~isempty(subLabel)
    opt.subjects = {subLabel};
  end

  if nargin < 3 || isempty(useRaw)
    useRaw = false;
  end

  opt.dir = [];

  if strcmp(task, 'MoAE')

    opt.dir.raw = fullfile(getMoaeDir(), 'inputs', 'raw');
    opt.dir.preproc = fullfile(getMoaeDir(), 'outputs', 'cpp_spm-preproc');
    opt.model.file = fullfile(getMoaeDir(), 'models', 'model-MoAE_smdl.json');

    opt.taskName = 'auditory';

    opt.result.Steps.Contrasts(1).Name = 'listening';
    opt.result.Steps.Contrasts(2).Name = 'listening_inf_baseline';

  elseif strcmp(task, 'MoAE-preproc')

    opt.dir.derivatives = fullfile(getDummyDataDir(), 'MoAE', 'derivatives');
    opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');
    opt.dir.stats = fullfile(opt.dir.derivatives, 'cpp_spm-stats');

    opt.model.file = fullfile(getMoaeDir(), 'models', 'model-MoAE_smdl.json');

    opt.taskName = 'auditory';

    opt.result.Steps.Contrasts(1).Name = 'listening';
    opt.result.Steps.Contrasts(2).Name = 'listening_inf_baseline';

  elseif strcmp(task, 'fmriprep')

    opt.taskName = 'balloonanalogrisktask';
    opt.dir.input = getFmriprepDir();
    opt.dir.raw = fullfile(getFmriprepDir(), '..', 'ds001');

    opt.model.file = fullfile(getDummyDataDir(),  'models', ...
                              ['model-' opt.taskName '_smdl.json']);

  elseif strcmp(task, 'fmriprep-synthetic')

    opt.taskName = 'nback';
    opt.dir.input = fullfile(getSyntheticDataDir(), 'derivatives', 'fmriprep');
    opt.dir.preproc = fullfile(getSyntheticDataDir(), 'derivatives', 'fmriprep');
    opt.dir.raw = getSyntheticDataDir();

    opt.model.file = fullfile(getDummyDataDir(),  'models', ...
                              ['model-' opt.taskName '_smdl.json']);

  else

    opt.taskName = task;
    opt.dir.derivatives = fullfile(getDummyDataDir(), 'derivatives');
    opt.dir.preproc = getDummyDataDir('preproc');
    opt.dir.stats = getDummyDataDir('stats');
    opt.model.file = fullfile(getDummyDataDir(),  'models', ...
                              ['model-' task '_smdl.json']);

  end

  opt = checkOptions(opt);

  if useRaw
    opt.dir.preproc = getDummyDataDir('raw');
  end

end
