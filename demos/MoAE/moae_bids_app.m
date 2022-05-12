% This script shows how to use the BIDS app like API of cpp_spm
%
% (C) Copyright 2022 Remi Gau

%% PREPROC
clear;
clc;

addpath(fullfile(pwd, '..', '..'));

bids_dir = fullfile(fileparts(mfilename('fullpath')), 'inputs', 'raw');

output_dir = fullfile(bids_dir, '..', '..', 'outputs', 'derivatives');

cpp_spm(bids_dir, output_dir, 'participant', ...
        'action', 'preprocess', ...
        'task', {'auditory'});

%% STATS
preproc_dir = fullfile(output_dir, 'cpp_spm-preproc');

model_file = fullfile(this_dir, 'models', 'model-MoAE_smdl.json');

opt.result.Nodes(1).Level = 'subject';
opt.result.Nodes(1).Contrasts(1).Name = 'listening_1';
opt.result.Nodes(1).Output.png = true();
opt.result.Nodes(1).Output.montage.do = true();
opt.result.Nodes(1).Output.montage.slices = -4:2:16;
opt.result.Nodes(1).Output.NIDM_results = true();

cpp_spm(bids_dir, output_dir, 'participant', ...
        'action', 'stats', ...
        'preproc_dir', preproc_dir, ...
        'model_file', model_file, ...
        'options', opt);
