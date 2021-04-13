% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function mask = createFuncWholeBrainMask(opt)

  % create segmented-skull stripped mean functional image

  % read the dataset
  [~, opt, BIDS] = getData(opt);
  subLabel = opt.subjects{1};

  % call/create the mask name
  [meanImage, meanFuncDir] = getMeanFuncFilename(BIDS, subLabel, opt);

  % name the output accordingto the input image
  maskFileName = ['m' strrep(meanImage, '.nii', '_mask.nii')];
  mask = fullfile(meanFuncDir, maskFileName);

  % ask if mask exist, if not create it:
  if ~exist(mask, 'file')

    % set batch order since there is dependencies
    opt.orderBatches.segment = 1;
    opt.orderBatches.skullStripping = 2;

    % opt for running skull strip on the mean image
    opt.skullStripMeanImg = 1;

    % make matlab batch for segment and skullstip
    matlabbatch = [];
    matlabbatch = setBatchSegmentation(matlabbatch, opt, opt.funcMaskFileName);

    matlabbatch = setBatchSkullStripping(matlabbatch, BIDS, opt, subLabel);
    % run spm
    saveAndRunWorkflow(matlabbatch, 'meanImage_segment_skullstrip', opt, subLabel);
  end
