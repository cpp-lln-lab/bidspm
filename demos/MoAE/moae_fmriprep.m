% This script will run the FFX and contrasts on it of the MoAE dataset
% using the fmriprep preprocessed data
%
% If you want to get the preprocessed data and you have datalad on your computer
% you can run the following commands to get the necessary data::
%
%   datalad install --source git@gin.g-node.org:/SPM_datasets/spm_moae_fmriprep.git \
%           inputs/fmriprep
%   cd inputs/fmriprep && datalad get *.json \
%                     */*/*tsv \
%                     */*/*json \
%                     */*/*desc-preproc*.nii.gz \
%                     */*/*desc-brain*.nii.gz
%
% Otherwise you also grab the data from OSF: https://osf.io/vufjs/download
%
% (C) Copyright 2019 Remi Gau

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

DOWNLOAD_DATA = false;
SMOOTH = false;

% Getting the raw dataset to get the events.tsv
download_moae_ds(DOWNLOAD_DATA);

%%
subject_label = {'01'};
task = {'auditory'};
space = {'MNI152NLin6Asym'};

WD = fileparts(mfilename('fullpath'));
bids_dir = fullfile(WD, 'inputs', 'raw');
fmriprep_dir = fullfile(WD, 'inputs', 'fmriprep');

% we need to specify where the smoothed data will go
output_dir = fullfile(WD, 'outputs', 'derivatives');

%% Copy and smooth
%
% fmriprep data is not smoothed so we need to do that first
%

if SMOOTH
  bidspm(fmriprep_dir, output_dir, 'subject', ...
         'action', 'smooth', ...
         'participant_label', subject_label, ...
         'task', task, ...
         'space', space, ...
         'fwhm', 8);
end

%% STATS

% create default model
bidspm(bids_dir, output_dir, 'dataset', ...
       'action', 'default_model', ...
       'participant_label', subject_label, ...
       'task', task, ...
       'space', space, ...
       'ignore', {'contrasts', 'transformations', 'dataset'});

% run model
model_file = fullfile(output_dir, 'models', 'model-defaultAuditory_smdl.json');

% Specify the result to show
%
% nodeName corresponds to the name of the Node in the BIDS stats model
opt.results(1).nodeName = 'run';
% this results corresponds to the name of the contrast in the BIDS stats model
opt.results(1).name = {'listening_1'};

% Specify how you want your output
% (all the following are on false by default)
opt.results(1).png = true();
opt.results(1).nidm = true();
opt.results(1).csv = true();
opt.results(1).threshSpm = true();
opt.results(1).binary = true();
opt.results(1).montage.do = true();
opt.results(1).montage.background = struct('suffix', 'T1w', ...
                                           'desc', 'preproc', ...
                                           'modality', 'anat');
opt.results(1).montage.slices = -4:2:16;

% the following "bids app" runs:
%
% - GLM specification + estimation,
% - compute contrasts and
% - show results
%
% that are otherwise handled by the bidsFFX.m and bidsResults.m workflows
%
% type bidspm('action', 'help')
% or see this page: https://bidspm.readthedocs.io/en/stable/bids_app_api.html
% for more information on what parameters are obligatory or optional
%

% where the smooth data is
preproc_dir = fullfile(output_dir, 'bidspm-preproc');

bidspm(bids_dir, output_dir, 'subject', ...
       'participant_label', subject_label, ...
       'action', 'stats', ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file, ...
       'roi_atlas', 'hcpex', ...
       'space', space, ...
       'fwhm', 8, ...
       'options', opt);
