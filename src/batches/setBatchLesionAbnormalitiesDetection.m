function matlabbatch = setBatchLesionAbnormalitiesDetection(matlabbatch, controlSegmentedImagesGM, patientSegmentedImagesGM, controlSegmentedImagesWM, patientSegmentedImagesWM)
  %
  % Creates a batch to detect lesion abnormalities
  %
  % USAGE::
  %
  %   matlabbatch = setBatchLesionAbnormalitiesDetection(matlabbatch, BIDS, opt, subLabel)
  %
  % :param matlabbatch: list of SPM batches
  % :type matlabbatch: structure
  %
  % :returns: - :matlabbatch: (structure)
  %
  % (C) Copyright 2021 CPP_SPM developers

  printBatchName('Lesion abnormalities');

  outliers_detection.step3mask_thr = 0;           % threshold for the mask
  outliers_detection.step3binary_thr = 0.3;       % binary lesion: threshold U
  outliers_detection.step3binary_size = 0.8;      % binary lesion: minimum size (in cm3)
  
  matlabbatch{end + 1}.spm.tools.ali.outliers_detection = outliers_detection; 
  
% rc1 images
  % 1. Define smoothed segmented tissue images of patients 
  matlabbatch{1}.spm.tools.ali.outliers_detection.step3tissue(1).step3patients = cellstr(char(patientSegmentedImagesGM));

  % 2. Define smoothed segmented tissue images of neurotypical controls 
  matlabbatch{1}.spm.tools.ali.outliers_detection.step3tissue(1).step3controls = cellstr(char(controlSegmentedImagesGM));

  % Specify alpha parameter
  matlabbatch{1}.spm.tools.ali.outliers_detection.step3tissue(1).step3Alpha = 0.5;
  % Specify lambda parameter
  matlabbatch{1}.spm.tools.ali.outliers_detection.step3tissue(1).step3Lambda = -4;

% rc2 images
  % 1. Define smoothed segmented tissue images of patients 
  matlabbatch{1}.spm.tools.ali.outliers_detection.step3tissue(2).step3patients = cellstr(char(patientSegmentedImagesWM));

  % 2. Define smoothed segmented tissue images of neurotypical controls 
  matlabbatch{1}.spm.tools.ali.outliers_detection.step3tissue(2).step3controls = cellstr(char(controlSegmentedImagesWM));

  % Specify alpha parameter
  matlabbatch{1}.spm.tools.ali.outliers_detection.step3tissue(2).step3Alpha = 0.5;
  % Specify lambda parameter
  matlabbatch{1}.spm.tools.ali.outliers_detection.step3tissue(2).step3Lambda = -4;
end
