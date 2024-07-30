function opt = setOptions(varargin)
  %
  % opt = setOptions(task, subLabel, ...
  %                  'useRaw', false, ...
  %                  'useTempDir', false, ...
  %                  'pipelineType', 'preproc');
  %

  % (C) Copyright 2021 bidspm developers

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
  addParameter(args, 'useTempDir', false);

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
    opt.dir.preproc = fullfile(getMoaeDir(), 'outputs', 'bidspm-preproc');

    opt.model.file = fullfile(getMoaeDir(), 'models', 'model-MoAE_smdl.json');

    opt.results(1).name = 'listening';
    opt.results(2).name = 'listening_inf_baseline';

  elseif strcmp(task, 'MoAE-fmriprep')

    task = {'auditory'};

    opt.space = {'MNI152NLin6Asym'};

    opt.dir.raw = fullfile(getMoaeDir(), 'inputs', 'raw');
    opt.dir.fmriprep = fullfile(getMoaeDir(), 'inputs', 'fmriprep');
    opt.dir.derivatives = fullfile(getMoaeDir(), 'outputs', 'derivatives');
    opt.dir.stats = fullfile(opt.dir.derivatives, 'bidspm-stats');

    opt.model.file = fullfile(getMoaeDir(), 'models', 'model-MoAE_smdl.json');

  elseif strcmp(task, 'MoAE-preproc')

    task = {'auditory'};

    opt.dir.derivatives = fullfile(getTestDataDir(), 'MoAE', 'derivatives');
    opt.dir.preproc = fullfile(opt.dir.derivatives, 'bidspm-preproc');
    opt.dir.stats = fullfile(opt.dir.derivatives, 'bidspm-stats');

    opt.model.file = fullfile(getMoaeDir(), 'models', 'model-MoAE_smdl.json');

    opt.results(1).name = 'listening';
    opt.results(2).name = 'listening_inf_baseline';

  elseif strcmp(task, 'facerep')

    opt.dir.derivatives = fullfile(getFaceRepDir(), 'outputs', 'derivatives');
    opt.dir.preproc = fullfile(opt.dir.derivatives, 'bidspm-preproc');
    opt.dir.input = opt.dir.preproc;
    opt.dir.stats = fullfile(opt.dir.derivatives, 'bidspm-stats');

    opt.model.file = fullfile(getFaceRepDir(), 'models', 'model-faceRepetition_smdl.json');

  elseif strcmp(task, 'fmriprep')

    task = {'balloonanalogrisktask'};

    opt.dir.raw = fullfile(getFmriprepDir(), '..', 'ds001');
    opt.dir.input = getFmriprepDir();

    opt.model.file = fullfile(getTestDataDir(),  'models', ...
                              ['model-' strjoin(task, '') '_smdl.json']);

  elseif strcmp(task, 'fmriprep-synthetic')

    task = {'nback'};

    opt.dir.input = fullfile(getSyntheticDataDir(), 'derivatives', 'fmriprep');
    opt.dir.raw = getSyntheticDataDir();
    opt.dir.preproc = fullfile(getSyntheticDataDir(), 'derivatives', 'fmriprep');

    opt.model.file = fullfile(getTestDataDir(),  'models', ...
                              ['model-' strjoin(task, '') '_smdl.json']);

  elseif strcmp(task, '3_groups')

    task = {'vismotion'};

    dataDir = fullfile(getTestDir(), 'data', '3_groups');

    opt.dir.raw = fullfile(dataDir, 'bidspm-raw');
    opt.dir.preproc = fullfile(dataDir, 'derivatives', 'bidspm-preproc');
    opt.dir.stats = fullfile(dataDir, 'derivatives', 'bidspm-stats');

    opt.model.file = fullfile(getTestDataDir(),  'models', 'model-vismotionOneWayANOVA_smdl.json');

  else

    opt.dir.raw = getTestDataDir('raw');
    opt.dir.derivatives = fullfile(getTestDataDir(), 'derivatives');
    opt.dir.preproc = getTestDataDir('preproc');
    opt.dir.stats = getTestDataDir('stats');

    opt.model.file = fullfile(getTestDataDir(),  'models', ...
                              ['model-' strjoin(task, '') '_smdl.json']);

  end

  opt.taskName = task;

  % not sure this is necessary as getOptionsFromModel takes care of that in checkOptions
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

  if args.Results.useRaw
    opt.dir.preproc = getTestDataDir('raw');
  end

  if args.Results.useTempDir
    tmpDir = tempName();
    copyfile(getTestDataDir(), tmpDir);
    if bids.internal.is_octave()
      tmpDir = fullfile(tmpDir, 'data');
    end
    dirsToUpdate = {'stats', 'derivatives', 'preproc', 'raw', 'input', 'jobs', 'output'};
    for i = 1:numel(dirsToUpdate)
      opt.dir.(dirsToUpdate{i}) = strrep(opt.dir.(dirsToUpdate{i}), ...
                                         getTestDataDir(), ...
                                         tmpDir);
    end
  end

end
