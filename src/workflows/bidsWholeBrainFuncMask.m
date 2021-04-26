function mask = bidsWholeBrainFuncMask(opt)
  %
  % create segmented-skull stripped mean functional image
  %
  % (C) Copyright 2020 CPP_SPM developers

  [BIDS, opt] = setUpWorkflow(opt, 'create brain mask from mean functional image');

  mask = cell(numel(opt.subjects), 1);

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    % call/create the mask name
    [meanImage, meanFuncDir] = getMeanFuncFilename(BIDS, subLabel, opt);
    meanFuncFileName = fullfile(meanFuncDir, meanImage);

    % name the output accordingto the input image
    maskFileName = ['m' strrep(meanImage, '.nii', '_mask.nii')];
    mask{iSub} = fullfile(meanFuncDir, maskFileName);

    % ask if mask exist, if not create it:
    if ~exist(mask{iSub}, 'file')

      % set batch order since there is dependencies
      opt.orderBatches.segment = 1;
      opt.orderBatches.skullStripping = 2;

      % make matlab batch for segment and skullstip
      matlabbatch = [];
      matlabbatch = setBatchSegmentation(matlabbatch, opt, meanFuncFileName);

      matlabbatch = setBatchSkullStripping(matlabbatch, BIDS, opt, subLabel);
      % run spm
      saveAndRunWorkflow(matlabbatch, 'meanImage_segment_skullstrip', opt, subLabel);
    end

  end
