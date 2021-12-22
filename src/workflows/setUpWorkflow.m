function [BIDS, opt] = setUpWorkflow(opt, workflowName, bidsDir)
  %
  % Calls some common functions to:
  % - check the configuraton,
  % - remove some old files from an eventual previous crash
  % - loads the layout of the BIDS dataset
  % - tries to open a graphic window
  %
  % USAGE::
  %
  %   [BIDS, opt, group] = setUpWorkflow(opt, workflowName, [bidsDir])
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions`` and ``loadAndCheckOptions``.
  % :type opt: structure
  % :param workflowName: name that will be printed on screen
  % :type workflowName: string
  % :param bidsDir:
  % :param bidsDir: string
  %
  % :returns:
  %
  %           - :BIDS: (structure) returned by ``getData``
  %           - :opt: options checked
  %           - :group:
  %
  % (C) Copyright 2019 CPP_SPM developers

  if nargin < 3
    bidsDir = opt.dir.input;
  end

  opt.globalStart = elapsedTime(opt, 'globalStart');

  opt = loadAndCheckOptions(opt);

  % load the subjects/Groups information and the task name
  [BIDS, opt] = getData(opt, bidsDir);

  cleanCrash();

  printWorkflowName(workflowName, opt);

  % TODO add workflow step to dataset description

  setGraphicWindow(opt);

  manageWorkersPool('open', opt);

end
