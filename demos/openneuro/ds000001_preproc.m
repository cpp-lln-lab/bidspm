% (C) Copyright 2020 CPP_SPM developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
cpp_spm();

% The directory where the data are located
root_dir = fileparts(mfilename('fullpath'));
bids_dir = fullfile(root_dir, 'inputs', 'ds000001');
output_dir = fullfile(root_dir, 'outputs', 'ds000001', 'derivatives');

%% Preprocessing
cpp_spm(bids_dir, output_dir, 'subject', ...
        'participant_label', {'01', '02'}, ...
        'action', 'preprocess', ...
        'task', {'balloonanalogrisktask'}, ...
        'space', {'IXI549Space'});
