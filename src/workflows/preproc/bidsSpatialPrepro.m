function matlabbatch = bidsSpatialPrepro(opt)
  %
  % Performs spatial preprocessing of the functional and anatomical data.
  %
  % The anatomical data are segmented, skull-stripped [and normalized to MNI space].
  %
  % The functional data are re-aligned (unwarped), coregistered with the anatomical,
  % [and normalized to MNI space].
  %
  % Assumes that :func:`bidsSTC` has already been run
  % if ``opt.stc.skip`` is not set to ``true``.
  %
  % USAGE::
  %
  %   bidsSpatialPrepro([opt])
  %
  % :type opt:  structure
  % :param opt: Options chosen for the analysis.
  %             See :func:`checkOptions`.
  %
  %
  % If you want to:
  %
  % - only do realign and not realign AND unwarp, make sure you set
  %   ``opt.realign.useUnwarp`` to ``false``.
  %
  % - normalize the data to MNI space, make sure
  %   ``opt.space`` includes ``IXI549Space``.
  %
  % See the `preprocessing` section of the FAQ to know
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

  % (C) Copyright 2019 bidspm developers

  %  TODO average T1s across sessions if necessary

  opt.pipeline.type = 'preproc';

  opt.dir.input = opt.dir.preproc;

  [BIDS, opt] = setUpWorkflow(opt, 'spatial preprocessing');

  opt.orderBatches.selectAnat = 1;
  if ~opt.anatOnly
    opt.orderBatches.realign = 2;
    opt.orderBatches.coregister = 3;
    opt.orderBatches.saveCoregistrationMatrix = 4;
  end

  % keep track of those flags
  % and reset them to their initial values for each subject
  % and we adapt them depending
  % if some subject have already been segmented / skulstripped
  segmentDo = opt.segment.do;
  skullstripDo = opt.skullstrip.do;

  srcMetadata = struct('RepetitionTime', [], ...
                       'SliceTimingCorrected', [], ...
                       'StartTime', []);
  for iSub = 1:numel(opt.subjects)

    opt.segment.do = segmentDo;
    opt.skullstrip.do = skullstripDo;

    matlabbatch = {};

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel, opt);

    matlabbatch = setBatchSelectAnat(matlabbatch, BIDS, opt, subLabel);

    if ~opt.realign.useUnwarp
      action = 'realign';
    else
      action = 'realignUnwarp';
    end
    [matlabbatch, voxDim, srcMetadata(iSub)] = setBatchRealign(matlabbatch, ...
                                                               BIDS, ...
                                                               opt, ...
                                                               subLabel, ...
                                                               action);

    % dependency from file selector ('Anatomical')
    matlabbatch = setBatchCoregistrationFuncToAnat(matlabbatch, BIDS, opt, subLabel);

    matlabbatch = setBatchSaveCoregistrationMatrix(matlabbatch, BIDS, opt, subLabel);

    anatFile = matlabbatch{1}.cfg_basicio.cfg_named_file.files{1}{1};

    % TODO refactor with bidsSegmentSkullstrip
    %% Skip segmentation / skullstripping if done previously
    if skullstripDo && ...
            ~opt.skullstrip.force && ...
            skullstrippingAlreadyDone(anatFile, BIDS)
      opt.skullstrip.do = false;
    end
    if segmentDo && ~opt.segment.force && ...
            segmentationAlreadyDone(anatFile, BIDS)
      opt.segment.do = false;
      % but if we must force the skullstripping
      % then we will need some segmentation input
    elseif opt.skullstrip.do && ...
            ~segmentationAlreadyDone(anatFile, BIDS)
      opt.segment.do = true;
    end

    [matlabbatch, opt] = setBatchSegmentation(matlabbatch, opt);

    matlabbatch = setBatchSkullStripping(matlabbatch, BIDS, opt, subLabel);
    opt.orderBatches.skullStripping = numel(matlabbatch) - 1;
    opt.orderBatches.skullStrippingMask = numel(matlabbatch);

    %% Normalization
    if ismember('IXI549Space', opt.space)
      % dependency from segmentation
      % dependency from coregistration
      % dependency from skullStripping
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

  end

  createdFiles = renameFiles(BIDS, opt);

  spaces = {'individual', 'IXI549Space'};
  for i = 1:numel(spaces)
    idx = ~cellfun('isempty', strfind(createdFiles, spaces{i}));
    transferMetadataFromJson(createdFiles(idx));
  end

  transferMetadataFromJson(createdFiles);

  bidsQAbidspm(opt);

end

function createdFiles = renameFiles(BIDS, opt)

  if ~opt.rename.do || opt.dryRun
    createdFiles = {};
    return
  end

  opt = setRenamingConfig(opt, 'SpatialPrepro');

  if ~opt.anatOnly

    for iSub = 1:numel(opt.subjects)

      subLabel = opt.subjects{iSub};

      % this is only necessary
      % if the rp_ files have not already been converted
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

  cleanUpWorkflow(opt);

  % TODO: when anatOnly update the res label for TPMs

  % TODO: when the voxDim is specified in opt,
  % it should probably be mentioned in the output BIDS name

  % TODO adapt spm_2_bids map to rename eventual files
  % that only have a "r" or "ra" prefix
  opt.query =  struct('modality', {{'anat', 'func'}});

  createdFiles = bidsRename(opt);

end
