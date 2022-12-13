% (C) Copyright 2019 bidspm developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

this_dir = fileparts(mfilename('fullpath'));
model_file = fullfile(this_dir, 'models', 'model-visMotionLoc_smdl.json');
root_dir = fullfile(this_dir, '..', '..', '..', '..');
bids_dir = fullfile(root_dir, 'inputs', 'raw');
output_dir = fullfile(root_dir, 'outputs', 'derivatives');
preproc_dir = fullfile(root_dir, 'outputs', 'derivatives', 'bidspm-preproc');

bidspm(bids_dir, output_dir, 'subject', ...
       'action', 'stats', ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file, ...
       'options', opt);

%% dataset level

bidspm(bids_dir, output_dir, 'dataset', ...
       'action', 'stats', ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file, ...
       'options', opt);
