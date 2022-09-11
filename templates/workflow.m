function workflow(opt)
  %
  % Brief workflow description
  %
  % USAGE::
  %
  %  workflow(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % (C) Copyright 2022 bidspm developers

  [BIDS, opt] = setUpWorkflow(opt, 'workflow name');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    matlabbatch = {};

    matlabbatch = setBatchSomeBatch(matlabbatch, BIDS, opt, subLabel);

    saveAndRunWorkflow(matlabbatch, 'workflow name', opt, subLabel);

  end

  bidsRename(opt);

end
