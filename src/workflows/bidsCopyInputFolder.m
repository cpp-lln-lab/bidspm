function bidsCopyInputFolder(varargin)
  %
  % Copies data from the ``opt.dir.input`` folder to the ``opt.dir.output`` folder
  %
  % Then it will search the derivatives directory for any zipped ``*.gz`` image
  % and uncompress the files of interest.
  %
  % USAGE::
  %
  %   bidsCopyInputFolder(opt, 'unzip', true, 'force', true)
  %
  % :param opt: Options chosen for the analysis.
  %             See checkOptions.
  % :type opt: structure
  %
  % :param unzip: defaults to true
  % :type unzip: boolean
  %
  % :param force: defaults to true
  % :type force: boolean
  %
  % See also: bids.copy_to_derivative
  %
  %

  % (C) Copyright 2019 bidspm developers

  TOLERANT = true;

  args = inputParser;

  addRequired(args, 'opt', @isstruct);
  addParameter(args, 'unzip', true, @islogical);
  addParameter(args, 'force', false, @islogical);
  addParameter(args, 'use_schema', true, @islogical);

  parse(args, varargin{:});

  opt = args.Results.opt;
  unzip = args.Results.unzip;
  force = args.Results.force;
  use_schema = args.Results.use_schema;

  opt = loadAndCheckOptions(opt);

  if ~isfield(opt, 'globalStart')
    opt.globalStart = elapsedTime(opt, 'globalStart');
  end

  cleanCrash();

  printWorkflowName('copy data', opt);

  % raw directory and derivatives directory
  createDerivativeDir(opt);

  [BIDS, opt] = getData(opt, opt.dir.input);

  skip_derivative_entities = false;
  if ~isfield(BIDS.description, 'DatasetType')  || ...
      (isfield(BIDS.description, 'DatasetType') && ...
       strcmp(BIDS.description.DatasetType, 'raw'))
    skip_derivative_entities = true;
  end
  if skip_derivative_entities
    entities_to_skip = {'hemi', 'space', 'seg', 'res', 'den', 'label', 'desc'};
    for i = 1:numel(entities_to_skip)
      if isfield(opt.query, entities_to_skip{i})
        opt.query = rmfield(opt.query, entities_to_skip{i});
      end
    end
  end

  for iModality = 1:numel(opt.query.modality)

    skip_dependencies = false;

    filter = opt.query;
    filter.modality = opt.query.modality{iModality};
    filter.sub = opt.subjects;

    if strcmp(filter.modality, 'func')
      filter.task = opt.taskName;
      if isempty(filter.task)
        filter.task = bids.query(BIDS, 'tasks', filter);
      end
    end

    pipeline_name = opt.pipeline.name;
    if ~strcmp(opt.pipeline.type, '')
      pipeline_name =  [pipeline_name '-' opt.pipeline.type];
    end

    % leave events files behind
    if ismember(pipeline_name, {'preproc', 'bidspm-preproc'})
      if ~isfield(filter, 'suffix')
        filter.suffix = {'^(?!(events)$).*$'};
      end
      skip_dependencies = true;
    end

    bids.copy_to_derivative(BIDS, ...
                            'pipeline_name', pipeline_name, ...
                            'out_path', fullfile(opt.dir.output, '..'), ...
                            'filter', filter, ...
                            'unzip', unzip, ...
                            'force', force, ...
                            'skip_dep', skip_dependencies, ...
                            'use_schema', use_schema, ...
                            'verbose', opt.verbosity > 0, ...
                            'tolerant', TOLERANT);

    % force grab the confounds for fmriprep
    if strcmp(filter.modality, 'func') && checkFmriprep(BIDS)

      if isfield(filter, 'desc')
        filter = rmfield(filter, 'desc');
      end
      filter = rmfield(filter, 'space');
      filter.suffix = {'regressors', 'timeseries', 'motion', 'outliers'};

      bids.copy_to_derivative(BIDS, ...
                              'pipeline_name', pipeline_name, ...
                              'out_path', fullfile(opt.dir.output, '..'), ...
                              'filter', filter, ...
                              'unzip', unzip, ...
                              'force', force, ...
                              'skip_dep', skip_dependencies, ...
                              'use_schema', use_schema, ...
                              'verbose', opt.verbosity > 0, ...
                              'tolerant', TOLERANT);

    end

  end

  % update dataset description
  % TODO refactor once bids.Description has been upgraded
  opt.dir.output = opt.dir.preproc;
  initBids(opt, 'force', true);

  cleanUpWorkflow(opt);

end
