function matlabbatch = setBatchLesionSegmentation(matlabbatch, BIDS, opt, subLabel)
  %
  % Creates a batch to segment the anatomical image for lesion detection
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSegmentationDetectLesion(matlabbatch, BIDS, opt, subLabel)
  %
  % :param matlabbatch: list of SPM batches
  % :type matlabbatch: structure
  %
  % :returns: - :matlabbatch: (structure)
  %
  % (C) Copyright 2021 CPP_SPM developers

  printBatchName('Lesion segmentation', opt);

  unified_segmentation = opt.toolbox.ALI.unified_segmentation;

  [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel);
  unified_segmentation.step1data{1} = fullfile(anatDataDir, anatImage);

  matlabbatch{end + 1}.spm.tools.ali.unified_segmentation = unified_segmentation;

end
