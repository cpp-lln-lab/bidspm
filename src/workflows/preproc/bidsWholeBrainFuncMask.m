function mask = bidsWholeBrainFuncMask(opt)
  %
  % Create segmented-skull stripped mean functional image
  %
  % USAGE::
  %
  %   mask = bidsWholeBrainFuncMask(opt)
  %

  % (C) Copyright 2020 bidspm developers

  opt.pipeline.type = 'preproc';

  opt.dir.input = opt.dir.preproc;

  [BIDS, opt] = setUpWorkflow(opt, 'create brain mask from mean functional image');

  mask = cell(numel(opt.subjects), 1);

  for iSub = 1:numel(opt.subjects)

    subLabel = opt.subjects{iSub};

    % call/create the mask name
    [meanImage, meanFuncDir] = getMeanFuncFilename(BIDS, subLabel, opt);
    meanFuncFilename = fullfile(meanFuncDir, meanImage);

    % name the output according to the input image
    maskFilename = ['m' strrep(meanImage, '.nii', '_mask.nii')];
    mask{iSub} = fullfile(meanFuncDir, maskFilename);

    % ask if mask exist, if not create it:
    if ~exist(mask{iSub}, 'file')

      % set batch order since there is dependencies
      opt.orderBatches.segment = 1;
      opt.orderBatches.skullStripping = 2;

      % make matlab batch for segment and skullstip
      matlabbatch = {};
      matlabbatch = setBatchSegmentation(matlabbatch, opt, meanFuncFilename);

      matlabbatch = setBatchSkullStripping(matlabbatch, BIDS, opt, subLabel);
      % run spm
      saveAndRunWorkflow(matlabbatch, 'meanImage_segment_skullstrip', opt, subLabel);
    end

  end

  cleanUpWorkflow(opt);

end
