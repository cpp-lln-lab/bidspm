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
  %   [~, opt, BIDS] = getData(opt);
  %
  %   createDefaultStatsModel(BIDS, opt);
  %
  % (C) Copyright 2020 CPP_SPM developers

  % TODO deal with the Transformations and Convolve fields

  trialTypeList = listAllTrialTypes(BIDS, opt);

  content = createEmptyStatsModel();
  
  content.Nodes{1} = rmfield(content.Nodes{1}, {'Transformations'}); 
  content.Nodes{2} = rmfield(content.Nodes{2}, {'Transformations'});   

  content = fillDefaultDesginMatrixAndContrasts(content, trialTypeList);

  content.Name = strjoin(opt.taskName, ' ');
  content.Description = ['default model for ' strjoin(opt.taskName, '')];
  content.Input.task = opt.taskName;

  % save the json file
  [~, ~, ~] = mkdir(fullfile(pwd, 'models'));
  filename = fullfile(pwd, 'models', ...
                      ['model-', ...
                       bids.internal.camel_case(['default ' strjoin(opt.taskName)]), ...
                       '_smdl.json']);

  bids.util.jsonwrite(filename, content);

  opt.model.file = filename;

end

function trialTypeList = listAllTrialTypes(BIDS, opt)
  % list all the *events.tsv files for that task and make a lis of all the
  % trial_types
  eventFiles = bids.query(BIDS, 'data', ...
                          'suffix', 'events', ...
                          'extension', '.tsv', ...
                          'task', opt.taskName);

  trialTypeList = {};

  for iFile = 1:size(eventFiles, 1)
    tmp = spm_load(eventFiles{iFile, 1});
    for iTrialType = 1:numel(tmp.trial_type)
      trialTypeList{end + 1, 1} = tmp.trial_type{iTrialType}; %#ok<*AGROW>
    end
  end

  trialTypeList = unique(trialTypeList);
  idx = ismember(trialTypeList, 'trial_type');
  if any(idx)
    trialTypeList{idx} = [];
  end

end

function content = fillDefaultDesginMatrixAndContrasts(content, trialTypeList)

  REALIGN_PARAMETERS_NAME = { ...
                             'trans_x', 'trans_y', 'trans_z', ...
                             'rot_x', 'rot_y', 'rot_z'};

  for iTrialType = 1:numel(trialTypeList)

    if  ~isempty(trialTypeList{iTrialType})
      trialTypeName = ['trial_type.' trialTypeList{iTrialType}];

      % subject
      content.Nodes{1}.Model.X{iTrialType} = trialTypeName;
      content.Nodes{1}.Model.HRF.Variables{iTrialType} = trialTypeName;

      % run
      content.Nodes{2}.Model.X{iTrialType} = trialTypeName;
      content.Nodes{2}.Model.HRF.Variables{iTrialType} = trialTypeName;

      for iNode = 1:numel(content.Nodes)
        content.Nodes{iNode}.DummyContrasts.Contrasts{iTrialType} = trialTypeName;
      end
    end

  end

  % add realign parameters
  for iRealignParam = 1:numel(REALIGN_PARAMETERS_NAME)
    content.Nodes{1}.Model.X{end + 1} = REALIGN_PARAMETERS_NAME{iRealignParam};
    content.Nodes{2}.Model.X{end + 1} = REALIGN_PARAMETERS_NAME{iRealignParam};
  end

end
