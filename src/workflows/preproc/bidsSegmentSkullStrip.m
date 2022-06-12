function matlabbatch = bidsSegmentSkullStrip(opt)
  %
  % Segments and skullstrips the anatomical image.
  % This workflow is already included in the bidsSpatialPrepro workflow.
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

  opt.pipeline.type = 'preproc';

  opt.dir.input = opt.dir.preproc;
  opt.query.modality = 'anat';
  opt.orderBatches.selectAnat = 1;
  opt.orderBatches.segment = 2;

  [BIDS, opt] = setUpWorkflow(opt, 'segmentation and skulltripping');

  % keep track of those flags and reset them to their initial values for each subject
  % and we adapt them depending if some subject have already been segmented / skulstripped
  segmentDo = opt.segment.do;
  skullstripDo = opt.skullstrip.do;

  for iSub = 1:numel(opt.subjects)

    opt.segment.do = segmentDo;
    opt.skullstrip.do = skullstripDo;

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    matlabbatch = {};
    matlabbatch = setBatchSelectAnat(matlabbatch, BIDS, opt, subLabel);

    % dependency from file selector ('Anatomical')
    anatFile = matlabbatch{1}.cfg_basicio.cfg_named_file.files{1}{1};

    %% Skip segmentation if done previously
    % modify opt to pass the information to the setBatch functions
    if skullstripDo && ~opt.skullstrip.force && skullstrippingAlreadyDone(anatFile, BIDS)
      opt.skullstrip.do = false;
    end

    if segmentDo && ~opt.segment.force && segmentationAlreadyDone(anatFile, BIDS)
      opt.segment.do = false;
      % but if we must force the skullstripping
      % then we will need some segmentation input
    elseif opt.skullstrip.do && ~segmentationAlreadyDone(anatFile, BIDS)
      opt.segment.do = true;
    end

    [matlabbatch, opt] = setBatchSegmentation(matlabbatch, opt);

    matlabbatch = setBatchSkullStripping(matlabbatch, BIDS, opt, subLabel);

    % if both segment and skullstrip were skipped we reset the batch
    if numel(matlabbatch) == 1
      matlabbatch = {};
    end

    saveAndRunWorkflow(matlabbatch, 'segment_skullstrip', opt, subLabel);

    if ~opt.dryRun && opt.rename
      renameSegmentParameter(BIDS, subLabel, opt);
    end

  end

  if opt.dryRun || ~opt.rename
    return
  end

  prefix = get_spm_prefix_list;
  opt.query.prefix = {prefix.bias_cor, 'c1', 'c2', 'c3', 'y_', 'iy_'};
  opt.query.suffix = opt.bidsFilterFile.t1w.suffix;
  bidsRename(opt);

end
