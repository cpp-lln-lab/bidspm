function opt = createDefaultStatsModel(BIDS, opt, ignore)
  %
  % Creates a default model json file for a BIDS dataset
  %
  % USAGE::
  %
  %   opt = createDefaultStatsModel(BIDS, opt)
  %
  % :param BIDS: dataset layout.
  %              See also: bids.layout, getData.
  % :type  BIDS: struct or path
  %
  % :param opt: Options chosen for the analysis.
  %             See also: ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type  opt: structure
  %
  % :param ignore: Optional. Cell string that can contain:
  %                - ``"Transformations"``
  %                - ``"Contrasts"``
  %                Can be used to avoid generating certain objects of the BIDS stats model.
  % :type  ignore: cellstr
  %
  % :return: opt
  %
  % Outputs a model file in the current directory::
  %
  %     fullfile(pwd, 'models', ['model-default' opt.taskName '_smdl.json']);
  %
  % This model has 3 "Nodes" in that order:
  %
  %  - Run level:
  %
  %     - will create a GLM with a design matrix that includes all
  %       all the possible type of trial_types that exist across
  %       all subjects and runs for the task specified in ``opt``,
  %       as well as the realignment parameters.
  %
  %     - use ``DummyContrasts`` to generate contrasts for each trial_type
  %       for each run. This can be useful to run MVPA analysis on the beta
  %       images of each run.
  %
  %  - Subject level:
  %
  %     - will create a GLM with a design matrix that includes all
  %       all the possible type of trial_types that exist across
  %       all subjects and runs for the task specified in ``opt``,
  %       as well as the realignment parameters.
  %
  %     - use ``DummyContrasts`` to generate contrasts for all each trial_type
  %       across runs
  %
  %    Dataset level:
  %
  %    - use ``DummyContrasts`` to generate contrasts for each trial_type
  %      for at the group level.
  %
  % EXAMPLE::
  %
  %   opt.taskName = 'myFascinatingTask';
  %   opt.dir.raw = fullfile(pwd, 'data', 'raw');
  %   opt = checkOptions(opt);
  %
  %   [BIDS, opt] = getData(opt, opt.dir.raw);
  %
  %   createDefaultStatsModel(BIDS, opt);
  %

  % (C) Copyright 2020 bidspm developers

  DEFAULT_CONFOUNDS = {'trans_?'
                       'rot_?'
                       'non_steady_state_outlier*'
                       'motion_outlier*'};

  if nargin < 3
    ignore = {};
  end

  bm = bids.Model();

  bm = bm.default(BIDS, opt.taskName);

  % add realign parameters
  for iRealignParam = 1:numel(DEFAULT_CONFOUNDS)
    bm.Nodes{1}.Model.X{end + 1} = DEFAULT_CONFOUNDS{iRealignParam};
  end
  bm.Nodes{1}.Model.Software = struct('SPM', struct('SerialCorrelation', 'FAST', ...
                                                    'InclusiveMaskingThreshold', 0.8));
  bm.Nodes{1}.Model.HRF.Model = 'spm';

  % remove session level
  [~, idx] = bm.get_nodes('Level', 'session');
  if ~isempty(idx)
    bm.Nodes(idx) = [];
  end

  % simplify higher levels
  levelsToUpdate = {'subject', 'dataset'};

  for i = 1:numel(levelsToUpdate)

    [~, idx] = bm.get_nodes('Level', levelsToUpdate{i});

    bm.Nodes{idx}.Model.X = {1};

    if strcmp(levelsToUpdate{i}, 'subject')
      bm.Nodes{idx}.GroupBy = {'subject', 'contrast'};
    elseif strcmp(levelsToUpdate{i}, 'subject')
      bm.Nodes{idx}.GroupBy = {'contrast'};
    end

    bm.Nodes{idx} = rmfield(bm.Nodes{idx}, 'Contrasts');
    bm.Nodes{idx}.DummyContrasts = rmfield(bm.Nodes{idx}.DummyContrasts, 'Contrasts');
    bm.Nodes{idx}.Model = rmfield(bm.Nodes{idx}.Model, 'Software');
    bm.Nodes{idx}.Model = rmfield(bm.Nodes{idx}.Model, 'Options');

  end

  if ismember('transformations', lower(ignore))
    bm.Nodes{1} = rmfield(bm.Nodes{1}, 'Transformations');
  end
  if ismember('contrasts', lower(ignore))
    bm.Nodes{1} = rmfield(bm.Nodes{1}, 'Contrasts');
  end

  for i = 1:numel(bm.Edges)
    bm.Edges(1) = [];
  end

  bm = bm.get_edges_from_nodes();

  bm.Input.space = opt.space;
  if numel(bm.Input.space) > 1
    msg = sprintf('Models can only accept one space.\nGot: %s', ...
                  createUnorderedList(bm.Input.space));
    id = 'tooManySpaces';
    logger('ERROR', msg, 'id', id, 'filename', mfilename);
  end

  bm = bm.update();

  filename = fullfile(opt.dir.derivatives, 'models', ...
                      ['model-', ...
                       bids.internal.camel_case(['default ' strjoin(opt.taskName)]), ...
                       '_smdl.json']);

  bm.write(filename);
  msg = sprintf('\nDefault model was created:\n\t%s', pathToPrint(filename));
  logger('INFO', msg, 'options', opt, 'filename', mfilename);

  opt.model.file = filename;

end
