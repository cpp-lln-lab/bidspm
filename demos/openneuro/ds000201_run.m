% (C) Copyright 2024 bidspm developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

% The directory where the data are located
root_dir = fileparts(mfilename('fullpath'));
bids_dir = fullfile(root_dir, 'inputs', 'ds000201');
output_dir = fullfile(root_dir, 'outputs', 'ds000201', 'derivatives');

participant_label = {'9001', '9002', '9003', '9004', '9005'};

%% Preprocessing
bidspm(bids_dir, output_dir, 'subject', ...
       'participant_label', participant_label, ...
       'action', 'preprocess', ...
       'anat_only', true, ...
       'space', {'individual', 'IXI549Space'}, ...
       'skip_validation', true);
