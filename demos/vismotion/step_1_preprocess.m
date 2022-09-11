% (C) Copyright 2019 bidspm developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
cpp_spm();

this_dir = fileparts(mfilename('fullpath'));
root_dir = fullfile(this_dir, '..', '..', '..', '..');

bids_dir = fullfile(root_dir, 'inputs', 'raw');
output_dir = fullfile(root_dir, 'outputs', 'derivatives');

cpp_spm(bids_dir, output_dir, 'subject', ...
        'action', 'preprocess', ...
        'task', {'visMotion'}, ...
        'ignore', {'unwarp', 'slicetiming'}, ...
        'space', {'IXI549Space'});
