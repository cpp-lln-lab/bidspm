function bidsTemplateWorkflow(opt)
  %
  %
  % (C) Copyright 2021 CPP_SPM developers

  [BIDS, opt] = setUpWorkflow(opt, 'workflow name');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel);

    matlabbatch = [];

    matlabbatch = setBatchSomeBatch(matlabbatch, BIDS, opt, subLabel);

    saveAndRunWorkflow(matlabbatch, 'workflow name', opt, subLabel);

  end

end
