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

% The directory where the data are located
WD = fileparts(mfilename('fullpath'));

opt.dir.raw = fullfile(WD, 'inputs', 'raw');
opt.dir.input = fullfile(WD, 'inputs', 'fmriprep');
opt.dir.derivatives = fullfile(WD, 'outputs', 'derivatives');

% we need to specify where the smoothed data will go
opt.pipeline.type = 'preproc';
opt.dir.preproc = fullfile(opt.dir.derivatives, 'bidspm-preproc');

%% Smooth the data
%
% fmriprep data is not smoothed so we need to do that first
%

opt.space = {'MNI152NLin6Asym'};

subject_label = '01';

opt.subjects = {subject_label};

opt.taskName = 'auditory';

opt.fwhm.func = 8;

opt = checkOptions(opt);

% specify some filter to decide which file to copy out of the frmiprep dataset
%
% this 2 step copy should disappear in future version.
%
% See: https://github.com/cpp-lln-lab/bidspm/issues/409
%

% copy the actual nifti images
opt.query.desc = {'preproc', 'brain'};
opt.query.suffix = {'T1w', 'bold', 'mask'};
opt.query.space = opt.space;
bidsCopyInputFolder(opt);

% then we can smooth
bidsSmoothing(opt);

%% STATS

% Create stats model
output_dir = fullfile(WD, 'outputs', 'derivatives');

bidspm(bids_dir, output_dir, 'dataset', ...
       'action', 'default_model', ...
       'space', {'MNI152NLin6Asym'}, ...
       'ignore', {'contrasts', 'transformations'});

% Run model
model_file = fullfile(output_dir, 'models', 'model-default_smdl.json');

subject_label = '01';

% Specify the result to show
%
% nodeName corresponds to the name of the Node in the BIDS stats model
opt.results(1).nodeName = 'run';
% this results corresponds to the name of the contrast in the BIDS stats model
opt.results(1).name = {'TODO'};

% Specify how you want your output
% (all the following are on false by default)
opt.results(1).png = true();
opt.results(1).montage.do = true();
opt.results(1).montage.background = struct('suffix', 'T1w', ...
                                           'desc', 'preproc', ...
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
% type bidspm('action', 'help')
% or see this page: https://bidspm.readthedocs.io/en/stable/bids_app_api.html
% for more information on what parameters are obligatory or optional
%

bidspm(bids_dir, output_dir, 'subject', ...
       'participant_label', {subject_label}, ...
       'action', 'stats', ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file, ...
       'space', {'MNI152NLin6Asym'}, ...
       'fwhm', 8, ...
       'options', opt);
