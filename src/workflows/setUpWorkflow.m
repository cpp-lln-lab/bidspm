function [BIDS, opt] = setUpWorkflow(opt, workflowName, bidsDir, indexData)
  %
  % Calls some common functions to:
  %
  %   - check the configuraton,
  %   - remove some old files from an eventual previous crash
  %   - loads the layout of the BIDS dataset
  %   - tries to open a graphic window
  %
  % USAGE::
  %
  %   [BIDS, opt, group] = setUpWorkflow(opt, workflowName, [bidsDir], indexData)
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See  also: checkOptions
  %             ``checkOptions`` and ``loadAndCheckOptions``.
  % :type opt: structure
  %
  % :param workflowName: name that will be printed on screen
  % :type workflowName: char
  %
  % :param bidsDir:
  % :param bidsDir: fullpath
  %
  % :param indexData: Set to ``false`` if you want to skip the datindexing with
  %                   ``getData``. Can be useful for some group level workflow
  %                   where indexing will happen later at the batch level.
  %                   This will also skip updating the subject list done by
  %                   ``getData``. Default to ``true``.
  % :param indexData: boolean
  %
  % :returns:
  %
  %           - :BIDS: (structure) returned by ``getData``
  %           - :opt: options checked
  %
  % (C) Copyright 2019 CPP_SPM developers

  BIDS = [];

  if nargin < 3 || isempty(bidsDir)
    bidsDir = opt.dir.input;
  end

  if nargin < 4
    indexData = true;
  end

  opt.globalStart = elapsedTime(opt, 'globalStart');

  opt = loadAndCheckOptions(opt);

  if indexData
    [BIDS, opt] = getData(opt, bidsDir);
  end

  if strcmp(opt.pipeline.type, 'stats') && isempty(opt.model.file)
    opt = createDefaultStatsModel(BIDS, opt);
  end

  opt = getOptionsFromModel(opt);

  cleanCrash();

  printWorkflowName(workflowName, opt);

  setGraphicWindow(opt);

end
