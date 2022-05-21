% This script shows how to use the BIDS app like API of cpp_spm
%
% (C) Copyright 2022 Remi Gau

%% PREPROC
clear;
clc;

addpath(fullfile(pwd, '..', '..'));

bids_dir = fullfile(fileparts(mfilename('fullpath')), 'inputs', 'raw');

output_dir = fullfile(bids_dir, '..', '..', 'outputs', 'derivatives');

cpp_spm(bids_dir, output_dir, 'subject', ...
        'action', 'preprocess', ...
        'task', {'auditory'}, ...
        'ignore', {'unwarp'}, ...
        'space', {'IXI549Space'});

%% STATS
addpath(fullfile(pwd, '..', '..'));

bids_dir = fullfile(fileparts(mfilename('fullpath')), 'inputs', 'raw');

output_dir = fullfile(bids_dir, '..', '..', 'outputs', 'derivatives');

preproc_dir = fullfile(output_dir, 'cpp_spm-preproc');

model_file = fullfile(pwd, 'models', 'model-MoAE_smdl.json');

opt.results.nodeName = 'subject_level';
opt.results.name = {'listening_1'};
opt.results.png = true();
opt.results.montage.do = true();
opt.results.montage.slices = -4:2:16;
opt.results.nidm = true();

cpp_spm(bids_dir, output_dir, 'subject', ...
        'action', 'stats', ...
        'preproc_dir', preproc_dir, ...
        'model_file', model_file, ...
        'options', opt);
