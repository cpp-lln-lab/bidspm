function matlabbatch = setBatchLesionSegmentation(matlabbatch, BIDS, opt, subLabel)
  %
  % Creates a batch to segment the anatomical image for lesion detection
  %
  % Requires the ALI toolbox: https://doi.org/10.3389/fnins.2013.00241
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

  % TODO
  % this needs to be changed
  % - to be consistent across subject
  % - to reslice the size of the mask that is then used for lesion detection
  %
  %   hdr = spm_vol(fullfile(anatDataDir, anatImage));
  %   voxRes = diag(hdr.mat);
  %   voxRes = min(voxRes(1:3));
  %   unified_segmentation.step1vox = abs(voxRes);

  unified_segmentation.step1data{1} = fullfile(anatDataDir, anatImage);

  matlabbatch{end + 1}.spm.tools.ali.unified_segmentation = unified_segmentation;

end
