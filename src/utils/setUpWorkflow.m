function [BIDS, opt] = setUpWorkflow(varargin)
  %
  % Calls some common functions to:
  %
  %   - check the configuration,
  %   - remove some old files from an eventual previous crash
  %   - loads the layout of the BIDS dataset
  %   - tries to open a graphic window
  %
  % USAGE::
  %
  %   [BIDS, opt] = setUpWorkflow(opt, workflowName, bidsDir, indexData, index_dependencies)
  %
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  % :type opt:  structure
  %
  % :param workflowName: name that will be printed on screen
  % :type  workflowName: char
  %
  % :param bidsDir: optional
  % :param bidsDir: fullpath, default = ''
  %
  % :param indexData: Set to ``false`` if you want to skip the datindexing with
  %                   ``getData``. Can be useful for some group level workflow
  %                   where indexing will happen later at the batch level.
  %                   This will also skip updating the subject list done by
  %                   ``getData``. Default to ``true``.
  % :param indexData: logical, default = true
  %
  % :param index_dependencies: Use ``'index_dependencies', true``
  %                            in bids.layout. default = true
  % :type  index_dependencies: logical
  %
  % :param layoutFilter: filter to pass to bids.layout. default = struct()
  % :type  layoutFilter: struct
  %
  %
  % :returns: ``BIDS`` layout returned by ``getData``, ``opt`` options checked
  % :rtype: structure, structure
  %

  % (C) Copyright 2019 bidspm developers

  BIDS = [];

  args = inputParser;

  addRequired(args, 'opt', @isstruct);
  addRequired(args, 'workflowName', @ischar);
  addOptional(args, 'bidsDir', '', @ischar);
  addOptional(args, 'indexData', true, @islogical);
  addOptional(args, 'indexDependencies', true, @islogical);
  addOptional(args, 'layoutFilter', struct(), @isstruct);

  parse(args, varargin{:});

  opt = args.Results.opt;
  workflowName = args.Results.workflowName;
  bidsDir = args.Results.bidsDir;
  indexData = args.Results.indexData;
  indexDependencies = args.Results.indexDependencies;
  layoutFilter = args.Results.layoutFilter;

  if isempty(bidsDir)
    bidsDir = opt.dir.input;
  end

  if ~isfield(opt, 'globalStart')
    opt.globalStart = elapsedTime(opt, 'globalStart');
  end

  opt = loadAndCheckOptions(opt);

  if indexData
    [BIDS, opt] = getData(opt, bidsDir, indexDependencies, layoutFilter);
  end

  if strcmp(opt.pipeline.type, 'stats') && ...
          (isempty(opt.model.file) && ~opt.pipeline.isBms)
    opt = createDefaultStatsModel(BIDS, opt);
  end

  opt = getOptionsFromModel(opt);

  cleanCrash();

  printWorkflowName(workflowName, opt);

  setGraphicWindow(opt);

end
