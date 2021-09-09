function bidsMidbrainReslice(opt)
  %
  %
  % (C) Copyright 2021 CPP_SPM developers
  % bidsResliceMidbrain(opt)
  % Relice midbrain masks at the correct resolution

  opt.dir.input = opt.dir.preproc;

  [BIDS, opt] = setUpWorkflow(opt, 'Midbrain Reslice');

  use_schema = false;
  BIDSroi =  bids.layout(opt.dir.roi, use_schema);

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    roiFiles = bids.query(BIDSroi, 'data', 'sub', subLabel);
    roiFiles = bids.query(BIDSroi, 'data', 'sub', '01', 'label', 'V1d', 'hemi', 'R');

    bids.query(BIDS, 'data', 'space', 'individual', 'desc', 'mean', 'suffix', 'bold');

    printProcessingSubject(iSub, subLabel);

    matlabbatch = {};

    matlabbatch = setBatchReslice(matlabbatch, opt, referenceImg, sourceImages, interp);

    saveAndRunWorkflow(matlabbatch, 'Midbrain Reslice', opt, subLabel);

  end

  bidsRename(opt);

end
