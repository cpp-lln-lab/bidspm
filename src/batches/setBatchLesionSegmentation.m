function matlabbatch = setBatchLesionSegmentation(matlabbatch, BIDS, opt, subLabel)
  %
  % Creates a batch to segment the anatomical image for lesion detection
  %
  % USAGE::
  %
  %   matlabbatch = setBatchSegmentationDetectLesion(matlabbatch, BIDS, opt, subID)
  %
  % :param matlabbatch: list of SPM batches
  % :type matlabbatch: structure
  %
  % :returns: - :matlabbatch: (structure)
  %
  % (C) Copyright 2021 CPP_SPM developers

  % TODO add test

  printBatchName('Lesion segmentation');

  unified_segmentation = opt.toolbox.ALI.unified_segmentation;

  % find anatomical file
  [anatImage, anatDataDir] = getAnatFilename(BIDS, subLabel, opt);
  unified_segmentation.step1data{1} = fullfile(anatDataDir, anatImage);

  matlabbatch{end + 1}.spm.tools.ali.unified_segmentation = unified_segmentation;

end
