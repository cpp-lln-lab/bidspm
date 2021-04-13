function matlabbatch = setBatchLesionAbnormalitiesDetection(matlabbatch, BIDS, opt, subLabel)
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

  % Defin smoothed segmented images of patients
  matlabbatch{1}.spm.tools.ali.outliers_detection.step3tissue.step3patients = '<UNDEFINED>';

  % Defin smoothed segmented images of neurotypical controls
  matlabbatch{1}.spm.tools.ali.outliers_detection.step3tissue.step3controls = '<UNDEFINED>';

  % Specify alpha parameter
  matlabbatch{1}.spm.tools.ali.outliers_detection.step3tissue.step3Alpha = 0.5;
  % Specify lambda parameter
  matlabbatch{1}.spm.tools.ali.outliers_detection.step3tissue.step3Lambda = -4;

  % define SPM folder
  spmDir = spm('dir');

  % specify lesion mask
  lesionMask = fullfile(spmDir, 'toolbox', 'ALI', 'Mask_image', 'mask_controls_vox2mm.nii');

  outliers_detection.step3mask_thr = 0;           % threshold for the mask
  outliers_detection.step3binary_thr = 0.3;       % binary lesion: threshold U
  outliers_detection.step3binary_size = 0.8;      % binary lesion: minimum size (in cm3)

  matlabbatch{end + 1}.spm.tools.ali.outliers_detection = outliers_detection;

end
