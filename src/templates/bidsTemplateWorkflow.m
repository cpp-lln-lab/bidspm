% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

function bidsTemplateWorkflow(opt)
  %
  %

  [BIDS, opt] = setUpWorkflow(opt, 'workflow name');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel);

    matlabbatch = [];

    %     matlabbatch = setBatchSTC(matlabbatch, BIDS, opt, subLabel);

    saveAndRunWorkflow(matlabbatch, 'workflow name', opt, subLabel);

  end

end
