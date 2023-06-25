% (C) Copyright 2019 bidspm developers

clear;
clc;

this_dir = fileparts(mfilename('fullpath'));
bidspm_dir = fullfile(this_dir, '..', '..');
addpath(bidspm_dir);
bidspm();

root_dir = fullfile(returnHomeDir(), 'visual_motion_localiser');

bids_dir = fullfile(root_dir, 'inputs', 'raw');
output_dir = fullfile(root_dir, 'outputs', 'derivatives');

mkdir(output_dir);

bidspm(bids_dir, output_dir, 'subject', ...
       'action', 'preprocess', ...
       'task', {'visMotion'}, ...
       'ignore', {'unwarp', 'slicetiming'}, ...
       'space', {'IXI549Space'});
