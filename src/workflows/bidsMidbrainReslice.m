function bidsMidbrainReslice(opt)
  %
  %
  % (C) Copyright 2021 CPP_SPM developers
  % bidsResliceMidbrain(opt)
  % Relice midbrain masks at the correct resolution

  [BIDS, opt] = setUpWorkflow(opt, 'Midbrain Reslice');

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel);

    matlabbatch = {};

    matlabbatch = setBatchReslice(matlabbatch, opt, referenceImg, sourceImages, interp);

    saveAndRunWorkflow(matlabbatch, 'Midbrain Reslice', opt, subLabel);

  end

  bidsRename(opt);

end
