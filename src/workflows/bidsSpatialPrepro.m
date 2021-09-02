function matlabbatch = bidsSpatialPrepro(opt)
  %
  % Performs spatial preprocessing of the functional and structural data.
  %
  % USAGE::
  %
  %   bidsSpatialPrepro([opt])
  %
  % :param opt: structure or json filename containing the options. See
  %             ``checkOptions()`` and ``loadAndCheckOptions()``.
  % :type opt: structure
  %
  % The anatomical data are segmented, skulls-stripped [and normalized to MNI space].
  %
  % The functional data are re-aligned (unwarped), coregistered with the structural,
  % the anatomical data is skull-stripped [and normalized to MNI space].
  %
  % If you want to:
  %
  % - only do realign and not realign AND unwarp, make sure you set
  %   ``opt.realign.useUnwarp`` to ``false``.
  % - normalize the data to MNI space, make sure
  %   ``opt.space`` includes ``MNI``.
  %
  % If you want to:
  %
  % - use another type of anatomical data than ``T1w`` as a reference or want to specify
  %   which anatomical session is to be used as a reference, you can set this in
  %   ``opt.anatReference``::
  %
  %     opt.anatReference.type = 'T1w';
  %     opt.anatReference.session = 1;
  %
  % .. TODO:
  %
  %  - average T1s across sessions if necessarry
  %
  % (C) Copyright 2019 CPP_SPM developers

  opt.dir.input = opt.dir.preproc;

  [BIDS, opt] = setUpWorkflow(opt, 'spatial preprocessing');

  opt.orderBatches.selectAnat = 1;
  opt.orderBatches.realign = 2;
  opt.orderBatches.coregister = 3;
  opt.orderBatches.saveCoregistrationMatrix = 4;

  for iSub = 1:numel(opt.subjects)

    matlabbatch = {};

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    matlabbatch = setBatchSelectAnat(matlabbatch, BIDS, opt, subLabel);

    % if action is emtpy then only realign will be done
    action = [];
    if ~opt.realign.useUnwarp
      action = 'realign';
    end
    [matlabbatch, voxDim] = setBatchRealign(matlabbatch, BIDS, opt, subLabel, action);

    % dependency from file selector ('Anatomical')
    matlabbatch = setBatchCoregistrationFuncToAnat(matlabbatch, BIDS, opt, subLabel);

    matlabbatch = setBatchSaveCoregistrationMatrix(matlabbatch, BIDS, opt, subLabel);

    % Skip segmentation and skullstripping if done previously
    anatFile = matlabbatch{1}.cfg_basicio.cfg_named_file.files{1}{1};
    p = bids.internal.parse_filename(anatFile);
    filter = p.entities;
    filter.suffix = 'probseg';
    tpm = bids.query(BIDS, 'data', filter);
    doSegmentation = opt.segment.force || isempty(tpm);

    if doSegmentation
      opt.orderBatches.segment = 5;
      opt.orderBatches.skullStripping = 6;
      opt.orderBatches.skullStrippingMask = 7;
      matlabbatch = setBatchSegmentation(matlabbatch, opt);
      matlabbatch = setBatchSkullStripping(matlabbatch, BIDS, opt, subLabel);
    end

    if ismember('MNI', opt.space)
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

    % clean up and rename files
    copyFigures(BIDS, opt, subLabel);

    opt = set_spm_2_bids_defaults(opt);

    if ~opt.dryRun

      % convert realignment files to confounds.tsv
      % and rename a few non-bidsy file
      rpFiles = spm_select('FPListRec', ...
                           fullfile(BIDS.pth, ['sub-' subLabel]), ...
                           ['^rp_.*sub-' subLabel '.*_task-' opt.taskName '.*_bold.txt$']);
      for iFile = 1:size(rpFiles, 1)
        rmInput = true;
        convertRealignParamToTsv(rpFiles(iFile, :), opt.spm_2_bids, rmInput);
      end

      renameSegmentParameter(BIDS, subLabel, opt);
      renameUnwarpParameter(BIDS, subLabel, opt);
    end

  end

  % TODO adapt spm_2_bids map to rename eventual files that only have a "r" or
  % "ra" prefix

  opt.query =  struct('modality', {{'anat', 'func'}});

  if ~opt.realign.useUnwarp

    opt.spm_2_bids = opt.spm_2_bids.add_mapping('prefix', opt.spm_2_bids.realign, ...
                                                'name_spec', opt.spm_2_bids.cfg.preproc);

    opt.spm_2_bids = opt.spm_2_bids.add_mapping('prefix', [opt.spm_2_bids.realign 'mean'], ...
                                                'name_spec', opt.spm_2_bids.cfg.preproc);
    opt.spm_2_bids = opt.spm_2_bids.flatten_mapping();
  end

  bidsRename(opt);

end
