function [BIDS, opt] = setUpWorkflow(opt, workflowName, BIDSdir)
  %
  % Calls some common functions to:
  % - check the configuraton,
  % - remove some old files from an eventual previous crash
  % - loads the layout of the BIDS dataset
  % - tries to open a graphic window
  %
  % USAGE::
  %
  %   [BIDS, opt, group] = setUpWorkflow(opt, workflowName)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions`` and ``loadAndCheckOptions``.
  % :type opt: structure
  % :param workflowName: name that will be printed on screen
  % :type workflowName: string
  %
  % :returns:
  %
  %           - :BIDS: (structure) returned by ``getData``
  %           - :opt: options checked
  %           - :group:
  %
  % (C) Copyright 2019 CPP_SPM developers

  if nargin < 3
    BIDSdir = opt.dir.input;
  end

  opt = loadAndCheckOptions(opt);

  % load the subjects/Groups information and the task name
  [BIDS, opt] = getData(opt, BIDSdir);

  cleanCrash();

  printWorkflowName(workflowName, opt);

  setGraphicWindow();

  manageWorkersPool('open', opt);

end
