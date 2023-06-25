% (C) Copyright 2019 bidspm developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

root_dir = fullfile(returnHomeDir(), "visual_motion_localiser");

this_dir = fileparts(mfilename('fullpath'));
model_file = fullfile(this_dir, 'models', 'model-visMotionLoc_smdl.json');
bids_dir = fullfile(root_dir, 'inputs', 'raw');
output_dir = fullfile(root_dir, 'outputs', 'derivatives');
preproc_dir = fullfile(root_dir, 'outputs', 'derivatives', 'bidspm-preproc');

bidspm(bids_dir, output_dir, 'subject', ...
       'action', 'stats', ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file);

%% dataset level

bidspm(bids_dir, output_dir, 'dataset', ...
       'action', 'stats', ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file);
