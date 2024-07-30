function matlabbatch = setBatchLesionAbnormalitiesDetection(matlabbatch, opt, images)
  %
  % Creates a batch to detect lesion abnormalities
  %
  % Requires the ALI toolbox: https://doi.org/10.3389/fnins.2013.00241
  %
  % USAGE::
  %
  %   matlabbatch = setBatchLesionAbnormalitiesDetection(matlabbatch, BIDS, opt, subLabel)
  %
  % :param matlabbatch: list of SPM batches
  % :type matlabbatch: structure
  %
  % :return: matlabbatch
  % :rtype: structure

  % (C) Copyright 2021 bidspm developers

  printBatchName('Lesion abnormalities', opt);

  outliers_detection = opt.toolbox.ALI.outliers_detection;

  outliers_detection.step3mask{1} = resizeAliMask(opt);

  for i = 1:size(images, 1)

    % 1. Define smoothed segmented tissue images of patients
    outliers_detection.step3tissue(i).step3patients = cellstr(char(images(i, 1).patients));

    % 2. Define smoothed segmented tissue images of neurotypical controls
    outliers_detection.step3tissue(i).step3controls = cellstr(char(images(i, 1).controls));

  end

  matlabbatch{end + 1}.spm.tools.ali.outliers_detection = outliers_detection;

end
