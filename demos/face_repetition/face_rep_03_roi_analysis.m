%
% Creates a ROI in MNI space from the retinotopic probablistic atlas.
%
% Creates its equivalent in subject space (inverse normalization).
%
% Then uses marsbar to run a ROI based GLM
%
% (C) Copyright 2019 Remi Gau

clear;
close all;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

this_dir = fileparts(mfilename('fullpath'));

%% Create roi

opt.dir.derivatives = fullfile(this_dir, 'outputs', 'derivatives');
opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');
opt.dir.roi = fullfile(opt.dir.derivatives, 'cpp_spm-roi');

opt.roi.atlas = 'wang';
opt.roi.name = {'V1v', 'V1d'};
opt.roi.space = {'individual'};

bidsCreateROI(opt);

%% run GLM

bids_dir = fullfile(this_dir, 'outputs', 'raw');
output_dir = fullfile(this_dir, 'outputs', 'derivatives');
preproc_dir = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');

opt.bidsFilterFile.roi.space = 'individual';

model_file = fullfile(this_dir, 'models', 'model-faceRepetition_smdl.json');

bidspm(bids_dir, output_dir, 'subject', ...
        'action', 'stats', ...
        'participant_label', {'01'}, ...
        'preproc_dir', preproc_dir, ...
        'model_file', model_file, ...
        'roi_based', true, ...
        'space', {'individual'}, ...
        'options', opt, ...
        'fwhm', 0);
