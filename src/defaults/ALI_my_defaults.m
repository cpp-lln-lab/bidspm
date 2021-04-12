% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function opt = ALI_my_defaults()

  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  %
  %
  % This is where we set the defautls we want to use for the ALE (lesion) toolbox.
  % These will overide the spm defaults.
  % When "not enough" information is specified in the batch files, SPM falls
  % back on the defaults to fill in the blanks. This allows to make the
  % script simpler.
  
  
    % Lesion segmentation defaults
  % ==========================================================================
  
%     % define SPM folder
%   spmDir = spm('dir');
% 
%   % specify Prior EXTRA class (lesion prior map)
%   lesionPriorMap = fullfile(spmDir, 'toolbox', 'ALI', 'Priors_extraClass', 'wc4prior0.nii');

  defaults.toolbox.ALI.unified_segmentation.step1prior = {lesionPriorMap};

  defaults.toolbox.ALI.unified_segmentation.step1niti = 2;                     % number of iterations
  defaults.toolbox.ALI.unified_segmentation.step1thr_prob = 0.333333333333333; % threshold probability
  defaults.toolbox.ALI.unified_segmentation.step1thr_size = 0.8;               % threshold size (in cm3)
  defaults.toolbox.ALI.unified_segmentation.step1coregister = 1;               % coregister in MNI space (yes: 1)
  defaults.toolbox.ALI.unified_segmentation.step1mask = {''};                  % specify cost function mask(optional)
  defaults.toolbox.ALI.unified_segmentation.step1vox = 2;                      % Voxel sizes (in mm)
  defaults.toolbox.ALI.unified_segmentation.step1fwhm = [8 8 8];               % Smooth: FWHM


    % Lesion abnormalities detection defaults
  % ==========================================================================
  
  % Specify alpha parameter
  defaults.toolbox.ALI.matlabbatch{1}.spm.tools.ali.outliers_detection.step3tissue.step3Alpha = 0.5;
  % Specify lambda parameter
  defaults.toolbox.ALI.matlabbatch{1}.spm.tools.ali.outliers_detection.step3tissue.step3Lambda = -4;

%   % define SPM folder
%   spmDir = spm('dir');

  % specify lesion mask
  defaults.toolbox.ALI.lesionMask = fullfile(spmDir, 'toolbox', 'ALI', 'Mask_image', 'mask_controls_vox2mm.nii');

  defaults.toolbox.ALI.outliers_detection.step3mask_thr = 0;           % threshold for the mask
  defaults.toolbox.ALI.outliers_detection.step3binary_thr = 0.3;       % binary lesion: threshold U
  defaults.toolbox.ALI.outliers_detection.step3binary_size = 0.8;      % binary lesion: minimum size (in cm3)
%   

end
  
  