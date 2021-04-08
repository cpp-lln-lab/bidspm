% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

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

  printBatchName('Lesion segmentation');

  % find anatomical file
  [anatImage, anatDataDir] = getAnatFilename(BIDS, subLabel, opt);
  unified_segmentation.step1data{1} = fullfile(anatDataDir, anatImage);

%   % define SPM folder
%   spmDir = spm('dir');
% 
%   % specify Prior EXTRA class (lesion prior map)
%   lesionPriorMap = fullfile(spmDir, 'toolbox', 'ALI', 'Priors_extraClass', 'wc4prior0.nii');
% 
%   unified_segmentation.step1prior = {lesionPriorMap};
% 
%   unified_segmentation.step1niti = 2;                     % number of iterations
%   unified_segmentation.step1thr_prob = 0.333333333333333; % threshold probability
%   unified_segmentation.step1thr_size = 0.8;               % threshold size (in cm3)
%   unified_segmentation.step1coregister = 1;               % coregister in MNI space (yes: 1)
%   unified_segmentation.step1mask = {''};                  % specify cost function mask(optional)
%   unified_segmentation.step1vox = 2;                      % Voxel sizes (in mm)
%   unified_segmentation.step1fwhm = [8 8 8];               % Smooth: FWHM

  matlabbatch{end + 1}.spm.tools.ali.unified_segmentation = unified_segmentation;

end
