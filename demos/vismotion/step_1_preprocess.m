% (C) Copyright 2019 bidspm developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

root_dir = fullfile(returnHomeDir(), "visual_motion_localiser");

bids_dir = fullfile(root_dir, 'inputs', 'raw');
output_dir = fullfile(root_dir, 'outputs', 'derivatives');

bidspm(bids_dir, output_dir, 'subject', ...
       'action', 'preprocess', ...
       'task', {'visMotion'}, ...
       'ignore', {'unwarp', 'slicetiming'}, ...
       'space', {'IXI549Space'});
