function opt = setOptions(varargin)
  %
  % opt = setOptions(task, subLabel, 'useRaw', false, 'pipelineType', 'preproc');
  %
  % (C) Copyright 2021 CPP_SPM developers

  generateLayoutMat();

  args = inputParser;

  default_subLabel = '';
  default_useRaw = false;
  default_pipelineType = 'preproc';

  charOrCell = @(x) ischar(x) || iscell(x);

  addRequired(args, 'task');
  addOptional(args, 'subLabel', default_subLabel, charOrCell);
  addParameter(args, 'useRaw', default_useRaw, @islogical);
  addParameter(args, 'pipelineType', default_pipelineType);

  parse(args, varargin{:});

  task = args.Results.task;
  subLabel = args.Results.subLabel;

  opt = setTestCfg();
  opt.pipeline.type = args.Results.pipelineType;
  opt.dir = [];

  if ~iscell(subLabel)
    subLabel = {subLabel};
  end
  opt.subjects = subLabel;

  if ~iscell(task)
    task = {task};
  end

  if strcmp(task, 'MoAE')

    task = {'auditory'};

    opt.dir.raw = fullfile(getMoaeDir(), 'inputs', 'raw');
    opt.dir.preproc = fullfile(getMoaeDir(), 'outputs', 'cpp_spm-preproc');

    opt.model.file = fullfile(getMoaeDir(), 'models', 'model-MoAE_smdl.json');

    opt.results(1).name = 'listening';
    opt.results(2).name = 'listening_inf_baseline';

  elseif strcmp(task, 'MoAE-preproc')

    task = {'auditory'};

    opt.dir.derivatives = fullfile(getDummyDataDir(), 'MoAE', 'derivatives');
    opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');
    opt.dir.stats = fullfile(opt.dir.derivatives, 'cpp_spm-stats');

    opt.model.file = fullfile(getMoaeDir(), 'models', 'model-MoAE_smdl.json');

    opt.results(1).name = 'listening';
    opt.results(2).name = 'listening_inf_baseline';

  elseif strcmp(task, 'facerep')

    opt.dir.derivatives = fullfile(getFaceRepDir(), 'outputs', 'derivatives');
    opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');
    opt.dir.input = opt.dir.preproc;
    opt.dir.stats = fullfile(opt.dir.derivatives, 'cpp_spm-stats');

    opt.model.file = fullfile(getFaceRepDir(), 'models', 'model-faceRepetition_smdl.json');

  elseif strcmp(task, 'fmriprep')

    task = {'balloonanalogrisktask'};

    opt.dir.raw = fullfile(getFmriprepDir(), '..', 'ds001');
    opt.dir.input = getFmriprepDir();

    opt.model.file = fullfile(getDummyDataDir(),  'models', ...
                              ['model-' strjoin(task, '') '_smdl.json']);

  elseif strcmp(task, 'fmriprep-synthetic')

    task = {'nback'};

    opt.dir.input = fullfile(getSyntheticDataDir(), 'derivatives', 'fmriprep');
    opt.dir.raw = getSyntheticDataDir();
    opt.dir.preproc = fullfile(getSyntheticDataDir(), 'derivatives', 'fmriprep');

    opt.model.file = fullfile(getDummyDataDir(),  'models', ...
                              ['model-' strjoin(task, '') '_smdl.json']);

  else

    opt.dir.raw = getDummyDataDir('raw');
    opt.dir.derivatives = fullfile(getDummyDataDir(), 'derivatives');
    opt.dir.preproc = getDummyDataDir('preproc');
    opt.dir.stats = getDummyDataDir('stats');

    opt.model.file = fullfile(getDummyDataDir(),  'models', ...
                              ['model-' strjoin(task, '') '_smdl.json']);

  end

  opt.taskName = task;

  if strcmp(opt.pipeline.type, 'stats')
    opt =  rmfield(opt, 'taskName');
    if isfield(opt, 'space')
      opt =  rmfield(opt, 'space');
    end
    opt.model.bm = BidsModel('file', opt.model.file);
  end

  if any(ismember(task, 'rest'))
    opt.model.file = '';
  end

  opt = checkOptions(opt);

  useRaw = args.Results.useRaw;
  if useRaw
    opt.dir.preproc = getDummyDataDir('raw');
  end

end
