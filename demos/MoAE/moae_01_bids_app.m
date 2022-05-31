% This script shows how to use the BIDS app like API of cpp_spm
%
% (C) Copyright 2022 Remi Gau

clear;
clc;

addpath(fullfile(pwd, '..', '..'));

%%
% will download the dataset from the FIL for the block design SPM tutorial
download_data = true;
clean = true;
download_moae_ds(download_data, clean);

%% PREPROC
%
% basic preprocessing.

subject_label = '01';

bids_dir = fullfile(fileparts(mfilename('fullpath')), 'inputs', 'raw');

output_dir = fullfile(bids_dir, '..', '..', 'outputs', 'derivatives');

% the following "bids app" call will run:
%
% - copies the necessary data from the raw to the derivative folder,
% - runs slice time correction
% - runs spatial preprocessing
%
% that are otherwise handled by the bidsCopyInputFolder.m, bidsSTC.m
% and bidsSpatialPrepro.m workflows
%
% type cpp_spm('action', 'help')
% or see this page: https://cpp-spm.readthedocs.io/en/dev/bids_app_api.html
% for more information on what parameters are obligatory or optional
%

cpp_spm(bids_dir, output_dir, 'subject', ...
        'participant_label', {subject_label}, ...
        'action', 'preprocess', ...
        'task', {'auditory'}, ...
        'ignore', {'unwarp'}, ...
        'space', {'IXI549Space'});

%% STATS
%
% This will run the subject level GLM and contrasts on it of the MOaE dataset
%
% Note:
%
% Results might be a bit different from those in the SPM manual as some
% default options are slightly different in this pipeline
% (e.g use of FAST instead of AR(1), motion regressors added)

addpath(fullfile(pwd, '..', '..'));

subject_label = '01';

bids_dir = fullfile(fileparts(mfilename('fullpath')), 'inputs', 'raw');
output_dir = fullfile(bids_dir, '..', '..', 'outputs', 'derivatives');
preproc_dir = fullfile(output_dir, 'cpp_spm-preproc');

model_file = fullfile(pwd, 'models', 'model-MoAE_smdl.json');

% Specify the result to show
%
% nodeName corresponds to the name of the Node in the BIDS stats model
opt.results(1).nodeName = 'run_level';
% this results corresponds to the name of the contrast in the BIDS stats model
opt.results(1).name = {'listening_1'};

% Specify how you want your output
% (all the following are on false by default)
opt.results(1).png = true();
opt.results(1).montage.do = true();
opt.results(1).montage.background = struct('suffix', 'mask', ...
                                           'modality', 'anat');
opt.results(1).montage.slices = -4:2:16;
opt.results(1).nidm = true();

% the following "bids app" runs:
%
% - GLM specification + estimation,
% - compute contrasts and
% - show results
%
% that are otherwise handled by the bidsFFX.m and bidsResults.m workflows
%
% type cpp_spm('action', 'help')
% or see this page: https://cpp-spm.readthedocs.io/en/dev/bids_app_api.html
% for more information on what parameters are obligatory or optional
%

cpp_spm(bids_dir, output_dir, 'subject', ...
        'participant_label', {subject_label}, ...
        'action', 'stats', ...
        'preproc_dir', preproc_dir, ...
        'model_file', model_file, ...
        'options', opt);
