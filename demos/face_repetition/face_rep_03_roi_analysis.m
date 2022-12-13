%
% Creates a ROI in MNI space from the retinotopic probabilistic atlas.
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

% skipping validation for now
% as raw data is not 100% valid
skip_validation = true;

this_dir = fileparts(mfilename('fullpath'));

%% Create roi
output_dir = fullfile(this_dir, 'outputs', 'derivatives');
preproc_dir = fullfile(output_dir, 'bidspm-preproc');

bidspm(pwd, output_dir, ...
       'action', 'create_roi', ...
       'preproc_dir', preproc_dir, ...
       'roi_atlas', 'wang', ...
       'roi_name', {'V1v', 'V1d'}, ...
       'space', {'IXI549Space', 'individual'});

%% run GLM
bids_dir = fullfile(this_dir, 'outputs', 'raw');
roi_dir = fullfile(output_dir, 'bidspm-roi');

model_file = fullfile(this_dir, 'models', 'model-faceRepetition_smdl.json');

bidspm(bids_dir, output_dir, 'subject', ...
       'action', 'stats', ...
       'participant_label', {'01'}, ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file, ...
       'roi_based', true, ...
       'roi_name', {'V1v', 'V1d'}, ...
       'roi_dir', roi_dir, ...
       'space', {'individual'}, ...
       'fwhm', 0, ...
       'skip_validation', skip_validation);
