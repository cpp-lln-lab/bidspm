function opt = createDefaultStatsModel(BIDS, opt)
  %
  % Creates a default model json file.
  % This model has 3 "Nodes" in that order:
  %
  % - Run level:
  %   - will create a GLM with a design matrix that includes all
  %     all the possible type of trial_types that exist across
  %     all subjects and runs for the task specified in ``opt``,
  %     as well as the realignment parameters.
  %
  %   - use DummyContrasts to generate contrasts for each trial_type
  %     for each run. This can be useful to run MVPA analysis on the beta
  %     images of each run.
  %
  % - Subject level:
  %   - will create a GLM with a design matrix that includes all
  %     all the possible type of trial_types that exist across
  %     all subjects and runs for the task specified in ``opt``,
  %     as well as the realignment parameters.
  %
  %   - use DummyContrasts to generate contrasts for all each trial_type
  %     across runs
  %
  % - Dataset level:
  %
  %   - use DummyContrasts to generate contrasts for each trial_type
  %     for at the group level.
  %
  % USAGE::
  %
  %   opt = createDefaultStatsModel(BIDS, opt)
  %
  % :output:
  %
  % - a model file in the current directory::
  %
  %     fullfile(pwd, 'models', ['model-default' opt.taskName '_smdl.json']);
  %
  % EXAMPLE::
  %
  %   opt.taskName = 'myFascinatingTask';
  %   opt.derivativesDir = fullfile(pwd, 'data', 'raw');
  %   opt = checkOptions(opt);
  %
  %   [BIDS, opt] = getData(opt, opt.dir.raw);
  %
  %   createDefaultStatsModel(BIDS, opt);
  %
  % (C) Copyright 2020 CPP_SPM developers

  % TODO deal with the Transformations and Convolve fields
  % TODO get MNI space from model

  DEFAULT_CONFOUNDS = {'trans_?'
                       'rot_?'
                       'non_steady_state_outlier*'
                       'motion_outlier*'};

  bm = bids.Model();

  bm = bm.default(BIDS);

  % add realign parameters
  for iRealignParam = 1:numel(DEFAULT_CONFOUNDS)
    bm.Nodes{1}.Model.X{end + 1} = DEFAULT_CONFOUNDS{iRealignParam};
  end
  bm.Nodes{1}.Model.Software = struct('SPM', struct('SerialCorrelation', 'FAST', ...
                                                    'HRFderivatives', 'Temporal'));

  bm = bm.update();

  filename = fullfile(pwd, 'models', ...
                      ['model-', ...
                       bids.internal.camel_case(['default ' strjoin(opt.taskName)]), ...
                       '_smdl.json']);

  bm.write(filename);

  opt.model.file = filename;

end
