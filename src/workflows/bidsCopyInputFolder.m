function bidsCopyInputFolder(opt, unzip)
  %
  % Copies the folders from the ``raw`` folder to the
  % ``derivatives`` folder, and will copy the dataset description and task json files
  % to the derivatives directory.
  %
  % Then it will search the derivatives directory for any zipped ``*.gz`` image
  % and uncompress the files for the task of interest.
  %
  % USAGE::
  %
  %   bidsCopyInputFolder(opt, 'unzip', true, 'force', 'false')
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  % :param unZip:
  % :type unZip: boolean
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
  skip_dependencies = false;

  for iModality = 1:numel(opt.query.modality)

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

    bids.copy_to_derivative(BIDS, ...
                            'pipeline_name', pipeline_name, ...
                            'out_path', fullfile(opt.dir.output, '..'), ...
                            'filter', filter, ...
                            'unzip', unzip, ...
                            'force', force, ...
                            'skip_dep', skip_dependencies, ...
                            'use_schema', use_schema, ...
                            'verbose', opt.verbosity > 0);

    printToScreen('\n\n', opt);
  end

  % update dataset description
  % TODO refactor once bids.Description has been upgraded
  opt.dir.output = opt.dir.preproc;
  initBids(opt, 'force', true);

  cleanUpWorkflow(opt);

end
