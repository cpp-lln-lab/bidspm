% This script will run the parametric model and contrasts
% on the the face repetition dataset from SPM.
%
%
% (C) Copyright 2019 Remi Gau

% TODO
% - create the contrast similar to the tuto

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

% skipping validation for now
% as raw data is not 100% valid
skip_validation = true;

this_dir = fileparts(mfilename('fullpath'));

bids_dir = fullfile(this_dir, 'outputs', 'raw');
output_dir = fullfile(this_dir, 'outputs', 'derivatives');
preproc_dir = fullfile(output_dir, 'bidspm-preproc');

model_file = fullfile(this_dir, 'models', 'model-faceRepetitionParametric_smdl.json');

subject_label = '01';

bidspm(bids_dir, output_dir, 'subject', ...
       'action', 'stats', ...
       'participant_label', {subject_label}, ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file, ...
       'skip_validation', skip_validation);
