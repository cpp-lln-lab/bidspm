function bidsSegmentSkullStrip(opt)
  %
  % Segments and skullstrips the anatomical image.
  %
  % USAGE::
  %
  %   bidsSegmentSkullStrip([opt])
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % (C) Copyright 2020 CPP_SPM developers

  [BIDS, opt] = setUpWorkflow(opt, 'segmentation and skulltripping');

  opt.orderBatches.selectAnat = 1;
  opt.orderBatches.segment = 2;

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel);

    matlabbatch = {};
    matlabbatch = setBatchSelectAnat(matlabbatch, BIDS, opt, subLabel);

    % dependency from file selector ('Anatomical')
    matlabbatch = setBatchSegmentation(matlabbatch, opt);

    matlabbatch = setBatchSkullStripping(matlabbatch, BIDS, opt, subLabel);

    saveAndRunWorkflow(matlabbatch, 'segment_skullstrip', opt, subLabel);

  end

end
