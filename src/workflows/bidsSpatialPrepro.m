function bidsSpatialPrepro(opt)
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
  % If you do not want to:
  %
  % - to perform realign AND unwarp, make sure you set
  %   ``opt.realign.useUnwarp`` to ``true``.
  % - normalize the data to MNI space, make sure you set
  %   ``opt.space`` to ``MNI``.
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

  [BIDS, opt] = setUpWorkflow(opt, 'spatial preprocessing');

  opt.orderBatches.selectAnat = 1;
  opt.orderBatches.realign = 2;
  opt.orderBatches.coregister = 3;
  opt.orderBatches.saveCoregistrationMatrix = 4;
  opt.orderBatches.segment = 5;
  opt.orderBatches.skullStripping = 6;
  opt.orderBatches.skullStrippingMask = 7;

  for iSub = 1:numel(opt.subjects)

    matlabbatch = {};

    subLabel = opt.subjects{iSub};

    printProcessingSubject(iSub, subLabel);

    matlabbatch = setBatchSelectAnat(matlabbatch, BIDS, opt, subLabel);

    % if action is emtpy then only realign will be done
    action = [];
    if ~opt.realign.useUnwarp
      action = 'realign';
    end
    [matlabbatch, voxDim] = setBatchRealign(matlabbatch, action, BIDS, opt, subLabel);

    % dependency from file selector ('Anatomical')
    matlabbatch = setBatchCoregistrationFuncToAnat(matlabbatch, BIDS, opt, subLabel);

    matlabbatch = setBatchSaveCoregistrationMatrix(matlabbatch, BIDS, opt, subLabel);

    % dependency from file selector ('Anatomical')
    matlabbatch = setBatchSegmentation(matlabbatch, opt);

    matlabbatch = setBatchSkullStripping(matlabbatch, BIDS, opt, subLabel);

    if strcmp(opt.space, 'MNI')
      % dependency from segmentation
      % dependency from coregistration
      matlabbatch = setBatchNormalizationSpatialPrepro(matlabbatch, opt, voxDim);
    end

    % if no unwarping was done on func, we reslice the func, so we can use
    % them for the functionalQA
    if ~opt.realign.useUnwarp
      matlabbatch = setBatchRealign(matlabbatch, 'reslice', BIDS, opt, subLabel);
    end

    batchName = ['spatial_preprocessing-' upper(opt.space(1)) opt.space(2:end)];

    saveAndRunWorkflow(matlabbatch, batchName, opt, subLabel);

    copyFigures(BIDS, opt, subLabel);

  end

end
