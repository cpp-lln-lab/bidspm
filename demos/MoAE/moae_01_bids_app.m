% This script shows how to use the bidspm BIDS app
%
% **Download**
%
% -  download the dataset from the FIL for the block design SPM tutorial
%
% **Preprocessing**
%
%   - copies the necessary data from the raw to the derivative folder,
%   - runs spatial preprocessing
%
% those are otherwise handled by the workflows:
%
%   - ``bidsCopyInputFolder.m``
%   - ``bidsSpatialPrepro.m``
%
% **stats**
%
% This will run the subject level GLM and contrasts on it of the MoaE dataset
%
%   - GLM specification + estimation
%   - compute contrasts
%   - show results
%
% that are otherwise handled by the workflows
%
%   - ``bidsFFX.m``
%   - ``bidsResults.m``
%
% .. note::
%
%       Results might be a bit different from those in the SPM manual as some
%       default options are slightly different in this pipeline
%       (e.g use of FAST instead of AR(1), motion regressors added)
%
%
% type `bidspm help` or `bidspm('action', 'help')`
% or see this page: https://bidspm.readthedocs.io/en/dev/bids_app_api.html
% for more information on what parameters are obligatory or optional
%
%
% (C) Copyright 2022 Remi Gau

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

%% Dopwnload the dataset
download_data = true;
clean = false;
download_moae_ds(download_data, clean);

%% PREPROC
subject_label = '01';

bids_dir = fullfile(fileparts(mfilename('fullpath')), 'inputs', 'raw');

output_dir = fullfile(bids_dir, '..', '..', 'outputs', 'derivatives');

bidspm(bids_dir, output_dir, 'subject', ...
       'participant_label', {subject_label}, ...
       'action', 'preprocess', ...
       'task', {'auditory'}, ...
       'ignore', {'unwarp', 'slicetiming'}, ...
       'space', {'IXI549Space'});

%% STATS
addpath(fullfile(pwd, '..', '..'));

subject_label = '01';

bids_dir = fullfile(fileparts(mfilename('fullpath')), 'inputs', 'raw');
output_dir = fullfile(bids_dir, '..', '..', 'outputs', 'derivatives');
preproc_dir = fullfile(output_dir, 'bidspm-preproc');

model_file = fullfile(pwd, 'models', 'model-MoAE_smdl.json');

% Specify the result to show

% nodeName corresponds to the name of the Node in the BIDS stats model
opt.results(1).nodeName = 'run_level';
% this results corresponds to the name of the contrast in the BIDS stats model
opt.results(1).name = {'listening_1'};

% Specify how you want your output
% (all the following are on false by default)
opt.results(1).png = true();
opt.results(1).csv = true();
opt.results(1).p = 0.05;
opt.results(1).MC = 'FWE';
opt.results(1).binary = true();
opt.results(1).montage.do = true();
opt.results(1).montage.background = struct('suffix', 'T1w', ...
                                           'desc', 'preproc', ...
                                           'modality', 'anat');
opt.results(1).montage.slices = -4:2:16;
opt.results(1).nidm = true();

opt.results(2).nodeName = 'run_level';
opt.results(2).name = {'listening_inf_baseline'};
opt.results(2).p = 0.01;
opt.results(2).k = 10;
opt.results(2).MC = 'none';
opt.results(2).csv = true;
opt.results(2).atlas = 'AAL';

bidspm(bids_dir, output_dir, 'subject', ...
       'participant_label', {subject_label}, ...
       'action', 'stats', ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file, ...
       'options', opt);
