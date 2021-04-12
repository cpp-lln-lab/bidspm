% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

function bidsCreatePhysioRegressor(opt)
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  % :param argin1: (dimension) obligatory argument. Lorem ipsum dolor sit amet,
  %                consectetur adipiscing elit. Ut congue nec est ac lacinia.
  % :type argin1: type
  % :param argin2: optional argument and its default value. And some of the
  %               options can be shown in litteral like ``this`` or ``that``.
  % :type argin2: string
  % :param argin3: (dimension) optional argument
  %
  % :returns: - :argout1: (type) (dimension)
  %           - :argout2: (type) (dimension)
  %
  % .. todo:
  %
  %    - item 1
  %    - item 2

  [BIDS, opt] = setUpWorkflow(opt, 'create physiological regressors');

  parfor iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel);

    matlabbatch = [];

    matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subLabel);

    saveAndRunWorkflow(matlabbatch, 'workflow name', opt, subLabel);

  end

end
