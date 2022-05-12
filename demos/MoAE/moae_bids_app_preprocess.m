% This script shows how to use the BIDS app like API of cpp_spm
%
% (C) Copyright 2022 Remi Gau

clear;
clc;

addpath(fullfile(pwd, '..', '..'));

bids_dir = fullfile(fileparts(mfilename('fullpath')), 'inputs', 'raw');

output_dir = fullfile(bids_dir, '..', 'derivatives');

cpp_spm(bids_dir, output_dir, 'participant', ...
        'action', 'preprocess', ...
        'task', {'auditory'});

% Equivalent to:
%
% cpp_spm(bids_dir, output_dir, 'participant', ...
%         'action', 'preprocess', ...
%         'task', {'auditory'}, ...
%         'participant_label', {'01'});
