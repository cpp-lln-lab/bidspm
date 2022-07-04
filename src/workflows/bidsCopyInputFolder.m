function bidsCopyInputFolder(varargin)
  %
  % Copies data from the ``opt.dir.input`` folder to the ``opt.dir.output`` folder
  %
  % Then it will search the derivatives directory for any zipped ``*.gz`` image
  % and uncompress the files for the task of interest.
  %
  % USAGE::
  %
  %   bidsCopyInputFolder(opt, 'unzip', true, 'force', true)
  %
  % :param opt: Options chosen for the analysis.
  %             See also: ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % :param unzip: defaults to true
  % :type unzip: boolean
  %
  % :param unzip: defaults to true
  % :type unzip: boolean
  %
  % See also: bids.copy_to_derivative
  %
  %
  % (C) Copyright 2019 CPP_SPM developers

  args = inputParser;

  addRequired(args, 'opt', @isstruct);
  addParameter(args, 'unzip', true, @islogical);
  addParameter(args, 'force', true, @islogical);

  parse(args, varargin{:});

  opt = args.Results.opt;
  unzip = args.Results.unzip;
  force = args.Results.force;

  opt = loadAndCheckOptions(opt);

  cleanCrash();

  printWorkflowName('copy data', opt);

  % raw directory and derivatives directory
  createDerivativeDir(opt);

  %% Loop through the groups, subjects, sessions
  [BIDS, opt] = getData(opt, opt.dir.input);

  use_schema = true;

  for iModality = 1:numel(opt.query.modality)

    skip_dependencies = false;

    filter = opt.query;
    filter.modality = opt.query.modality{iModality};
    filter.sub = opt.subjects;

    if strcmp(filter.modality, 'func')
      filter.task = opt.taskName;
    end

    pipeline_name = opt.pipeline.name;
    if ~strcmp(opt.pipeline.type, '')
      pipeline_name =  [pipeline_name '-' opt.pipeline.type];
    end

    % leave events files behind
    if ismember(pipeline_name, {'preproc', 'cpp_spm-preproc'})
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
                            'verbose', opt.verbosity > 0);

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
                              'verbose', opt.verbosity > 0);

    end

    printToScreen('\n\n', opt);
  end

  % update dataset description
  % TODO refactor once bids.Description has been upgraded
  opt.dir.output = opt.dir.preproc;
  initBids(opt, 'force', true);

  cleanUpWorkflow(opt);

end
