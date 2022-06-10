% (C) Copyright 2019 CPP_SPM developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
cpp_spm();

this_dir = fileparts(mfilename('fullpath'));
model_file = fullfile(this_dir, 'models', 'model-visMotionLoc_smdl.json');
root_dir = fullfile(this_dir, '..', '..', '..', '..');
bids_dir = fullfile(root_dir, 'inputs', 'raw');
output_dir = fullfile(root_dir, 'outputs', 'derivatives');
preproc_dir = fullfile(root_dir, 'outputs', 'derivatives', 'cpp_spm-preproc');

% TODO via BIDS api
% bidsRFX('meananatandmask', opt);

opt = get_option_stats('subject');

cpp_spm(bids_dir, output_dir, 'subject', ...
        'action', 'stats', ...
        'preproc_dir', preproc_dir, ...
        'model_file', model_file, ...
        'options', opt);

opt = get_option_stats('dataset');

cpp_spm(bids_dir, output_dir, 'dataset', ...
        'action', 'stats', ...
        'preproc_dir', preproc_dir, ...
        'model_file', model_file, ...
        'options', opt);
