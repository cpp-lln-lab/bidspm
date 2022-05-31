% This script will run the FFX and contrasts on it of the MoAE dataset
% using the fmriprep preprocessed data
%
% If you want to get the preprocessed data and you have datalad on your computer
% you can run the following commands to get the necesary data::
%
%
%   datalad install --source git@gin.g-node.org:/SPM_datasets/spm_moae_fmriprep.git \
%           inputs/fmriprep
%   cd inputs/fmriprep && datalad get *.json \
%                     */*/*tsv \
%                     */*/*json \
%                     */*/*desc-preproc*.nii.gz \
%                     */*/*desc-brain*.nii.gz
%
% Otherwise you also grad the data from OSF:
% https://osf.io/vufjs/download
%
% (C) Copyright 2019 Remi Gau

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
cpp_spm();

% Getting the raw dataset
download_data = true;
download_moae_ds(download_data);

% The directory where the data are located
WD = fileparts(mfilename('fullpath'));

opt.dir.raw = fullfile(WD, 'inputs', 'raw');
opt.dir.input = fullfile(WD, 'inputs', 'fmriprep');

opt.dir.derivatives = fullfile(WD, 'outputs', 'derivatives');

%% Smooth the data
%
% fmriprep data is not smoothed so we need to do that first
%

% we need to specify where the smoothed data will go
opt.pipeline.type = 'preproc';
opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');

% specify some filter to decide which file to copy out of the frmipre dataset
opt.query.desc = {'preproc', 'confounds', 'brain'};
opt.query.suffix = {'T1w', 'bold', 'mask', 'timeseries'};
opt.space = {'MNI152NLin6Asym'};
opt.query.space = opt.space;

subject_label = '01';

opt.subjects = {subject_label};

opt.taskName = 'auditory';

opt.fwhm.func = 8;

opt = checkOptions(opt);

bidsCopyInputFolder(opt);

bidsSmoothing(opt);

%% STATS

clear;
clc;

WD = fileparts(mfilename('fullpath'));

subject_label = '01';

bids_dir = fullfile(WD, 'inputs', 'raw');
output_dir = fullfile(WD, 'outputs', 'derivatives');
preproc_dir = fullfile(output_dir, 'cpp_spm-preproc');

model_file = fullfile(pwd, 'models', 'model-MoAEfmriprep_smdl.json');

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
% type cpp_spm('action', 'help')
% or see this page: https://cpp-spm.readthedocs.io/en/dev/bids_app_api.html
% for more information on what parameters are obligatory or optional
%

cpp_spm(bids_dir, output_dir, 'subject', ...
        'participant_label', {subject_label}, ...
        'action', 'stats', ...
        'preproc_dir', preproc_dir, ...
        'model_file', model_file, ...
        'fwhm', 8, ...
        'options', opt);
