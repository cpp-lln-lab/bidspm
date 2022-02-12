% This script will run the subject level GLM to denoise the data:
% with no condition in the design matric and only motion confounds.
%
% The residuals correspond to the time series of denoised data.
%
% (C) Copyright 2022 Remi Gau

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
cpp_spm('init');

opt = moae_get_option_stats();
opt.model.file = fullfile(pwd, 'models', 'model-denoiseOnly_smdl.json');
opt.glm.keepResiduals = true;

bidsFFX('specifyAndEstimate', opt);
