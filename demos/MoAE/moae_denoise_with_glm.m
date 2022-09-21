% This script will run the subject level GLM to denoise the data:
% with no condition in the design matrix and only motion confounds.
%
% The residuals correspond to the time series of denoised data.
%
% (C) Copyright 2022 Remi Gau

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

bids_dir = fullfile(fileparts(mfilename('fullpath')), 'inputs', 'raw');
output_dir = fullfile(bids_dir, '..', '..', 'outputs', 'derivatives');
preproc_dir = fullfile(output_dir, 'bidspm-preproc');

model_file = fullfile(pwd, 'models', 'model-denoiseOnly_smdl.json');

opt.glm.keepResiduals = true;

bidspm(bids_dir, output_dir, 'subject', ...
       'action', 'stats', ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file, ...
       'options', opt);
