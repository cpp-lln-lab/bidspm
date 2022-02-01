function matlabbatch = bidsSpatialPrepro(opt)
  %
  % Performs spatial preprocessing of the functional and anatomical data.
  %
  % USAGE::
  %
  %   bidsSpatialPrepro([opt])
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % The anatomical data are segmented, skull-stripped [and normalized to MNI space].
  %
  % The functional data are re-aligned (unwarped), coregistered with the anatomical,
  % [and normalized to MNI space].
  %
  % Assumes that ``bidsSTC()`` has already been run if ``opt.stc.skip`` is not set
  % to ``true``.
  %
  % If you want to:
  %
  % - only do realign and not realign AND unwarp, make sure you set
  %   ``opt.realign.useUnwarp`` to ``false``.
  % - normalize the data to MNI space, make sure
  %   ``opt.space`` includes ``IXI549Space``.
  %
  % See the :ref:`preprocessing resampling` section of the FAQ to know
  % at what resolution files are resampled during normalization.
  %
  % If you want to:
  %
  % - use another type of anatomical data than ``T1w`` as a reference or want to specify
  %   which anatomical session is to be used as a reference, you can set this in
  %   ``opt.bidsFilterFiler.t1w``::
  %
  %     opt.bidsFilterFiler.t1w.suffix = 'T1w';
  %     opt.bidsFilterFiler.t1w.ses = 1;
  %
  %
  % (C) Copyright 2019 CPP_SPM developers

  %  TODO average T1s across sessions if necessarry

  opt.pipeline.type = 'preproc';

  opt.dir.input = opt.dir.preproc;

  [BIDS, opt] = setUpWorkflow(opt, 'spatial preprocessing');

  opt.orderBatches.selectAnat = 1;
  lastBatch = 1;
  if ~opt.anatOnly
    opt.orderBatches.realign = 2;
    opt.orderBatches.coregister = 3;
    opt.orderBatches.saveCoregistrationMatrix = 4;
    lastBatch = 4;
  end

  for iSub = 1:numel(opt.subjects)

    matlabbatch = {};

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    matlabbatch = setBatchSelectAnat(matlabbatch, BIDS, opt, subLabel);

    if ~opt.realign.useUnwarp
      [matlabbatch, voxDim] = setBatchRealign(matlabbatch, BIDS, opt, subLabel, 'realign');
    else
      [matlabbatch, voxDim] = setBatchRealign(matlabbatch, BIDS, opt, subLabel);
    end

    % dependency from file selector ('Anatomical')
    matlabbatch = setBatchCoregistrationFuncToAnat(matlabbatch, BIDS, opt, subLabel);

    matlabbatch = setBatchSaveCoregistrationMatrix(matlabbatch, BIDS, opt, subLabel);

    % Skip segmentation and skullstripping if done previously
    anatFile = matlabbatch{1}.cfg_basicio.cfg_named_file.files{1}{1};
    anatFile = bids.internal.parse_filename(anatFile);
    filter = anatFile.entities;
    filter.modality = 'anat';

    filter.suffix = anatFile.suffix;
    filter.desc = 'biascor';
    biasCorrectedImage = bids.query(BIDS, 'data', filter);

    filter.suffix = 'probseg';
    filter = rmfield(filter, 'desc');
    tpm = bids.query(BIDS, 'data', filter);

    doSegmentAndSkullstrip = opt.segment.force || isempty(tpm) || isempty(biasCorrectedImage);

    if doSegmentAndSkullstrip
      opt.orderBatches.segment = lastBatch + 1;
      opt.orderBatches.skullStripping = lastBatch + 2;
      opt.orderBatches.skullStrippingMask = lastBatch + 3;
      matlabbatch = setBatchSegmentation(matlabbatch, opt);
      matlabbatch = setBatchSkullStripping(matlabbatch, BIDS, opt, subLabel);
    end

    if ismember('IXI549Space', opt.space)
      % dependency from segmentation
      % dependency from coregistration
      matlabbatch = setBatchNormalizationSpatialPrepro(matlabbatch, BIDS, opt, voxDim);
    end

    % if no unwarping was done on func, we reslice the func,
    % so we can use them later
    if ~opt.realign.useUnwarp
      matlabbatch = setBatchRealign(matlabbatch, BIDS, opt, subLabel, 'reslice');
    end

    batchName = ['spatial_preprocessing-' strjoin(opt.space, '-')];

    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

    %% clean up and rename files
    copyFigures(BIDS, opt, subLabel);

    if doSegmentAndSkullstrip && ~opt.dryRun
      spmup_comp_dist2surf(matlabbatch{1}.cfg_basicio.cfg_named_file.files{1}{1});
    end

  end

  if ~opt.dryRun
    functionalQA(opt);
  end

  renameFile(BIDS, opt);

  if ~opt.dryRun && opt.rename
    anatomicalQA(opt);
  end

end

function renameFile(BIDS, opt)

  if ~opt.rename
    return
  end

  opt = set_spm_2_bids_defaults(opt);

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    if ~opt.dryRun && ~opt.anatOnly

      % this is only necessary if the rp_ files have not already been converted
      % and deleted by functionalQA
      for iTask = 1:numel(opt.taskName)
        rpFiles = spm_select('FPListRec', ...
                             fullfile(BIDS.pth, ['sub-' subLabel]), ...
                             ['^rp_.*sub-', subLabel, ...
                              '.*_task-', opt.taskName{iTask}, ...
                              '.*_' opt.bidsFilterFile.bold.suffix '.txt$']);
        for iFile = 1:size(rpFiles, 1)
          rmInput = true;
          convertRealignParamToTsv(rpFiles(iFile, :), opt, rmInput);
        end
      end

      renameSegmentParameter(BIDS, subLabel, opt);
      renameUnwarpParameter(BIDS, subLabel, opt);

    end

  end

  % TODO: when anatOnly update the res label for TPMs

  % TODO: when the voxDim is specified in opt,
  % it should probably be mentioned in the output BIDS name

  % TODO adapt spm_2_bids map to rename eventual files
  % that only have a "r" or "ra" prefix
  opt.query =  struct('modality', {{'anat', 'func'}});

  if ~opt.realign.useUnwarp
    opt.spm_2_bids = opt.spm_2_bids.add_mapping('prefix', opt.spm_2_bids.realign, ...
                                                'name_spec', opt.spm_2_bids.cfg.preproc);

    opt.spm_2_bids = opt.spm_2_bids.add_mapping('prefix', [opt.spm_2_bids.realign 'mean'], ...
                                                'name_spec', opt.spm_2_bids.cfg.mean);
    opt.spm_2_bids = opt.spm_2_bids.flatten_mapping();
  end

  bidsRename(opt);

end
