% This script shows how to use the BIDS app like API of cpp_spm
%
% (C) Copyright 2022 Remi Gau

clear;
clc;

addpath(fullfile(pwd, '..', '..'));

%%
download_data = true;
clean = true;
download_moae_ds(download_data, clean);

%% PREPROC

% will download the dataset from the FIL for the block design SPM tutorial
% and will run the basic preprocessing.

bids_dir = fullfile(fileparts(mfilename('fullpath')), 'inputs', 'raw');

output_dir = fullfile(bids_dir, '..', '..', 'outputs', 'derivatives');

cpp_spm(bids_dir, output_dir, 'subject', ...
        'action', 'preprocess', ...
        'task', {'auditory'}, ...
        'ignore', {'unwarp'}, ...
        'space', {'IXI549Space'});

%% STATS
% This script will run the subject level GLM and contrasts on it of the MoAE dataset
%
% Results might be a bit different from those in the manual as some
% default options are slightly different in this pipeline
% (e.g use of FAST instead of AR(1), motion regressors added)

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
