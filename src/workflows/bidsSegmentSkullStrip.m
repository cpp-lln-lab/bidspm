function bidsSegmentSkullStrip(opt)
  %
  % Segments and skullstrips the anatomical image.
  %
  % USAGE::
  %
  %   bidsSegmentSkullStrip(opt)
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  %
  % (C) Copyright 2020 CPP_SPM developers

  opt.dir.input = opt.dir.preproc;
  opt.query.modality = 'anat';
  opt.orderBatches.selectAnat = 1;
  opt.orderBatches.segment = 2;

  [BIDS, opt] = setUpWorkflow(opt, 'segmentation and skulltripping');

  runTime = [];

  for iSub = 1:numel(opt.subjects)

    subjectStart = elapsedTime(opt, 'start');

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    matlabbatch = {};
    matlabbatch = setBatchSelectAnat(matlabbatch, BIDS, opt, subLabel);

    % dependency from file selector ('Anatomical')
    matlabbatch = setBatchSegmentation(matlabbatch, opt);

    matlabbatch = setBatchSkullStripping(matlabbatch, BIDS, opt, subLabel);

    saveAndRunWorkflow(matlabbatch, 'segment_skullstrip', opt, subLabel);

    if ~opt.dryRun
      renameSegmentParameter(BIDS, subLabel, opt);
    end

    [~, runTime] = elapsedTime(opt, 'stop', subjectStart, runTime, numel(opt.subjects));

  end

  cleanUpWorkflow(opt);

  prefix = get_spm_prefix_list;
  opt.query.prefix = prefix.stc;
  opt.query.prefix = {prefix.bias_cor, 'c1', 'c2', 'c3', 'y_', 'iy_'};
  opt.query.suffix = opt.anatReference.type;
  bidsRename(opt);

end
