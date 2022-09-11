% Runs smoothing and stats on ds002799 from openneuro
%
% To get the data run (requires datalad):
%
% bash ds002799_install_and_get_data.sh
%
%
% (C) Copyright 2022 Remi Gau

clear;
close all;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

% The directory where the data are located
root_dir = fullfile(fileparts(mfilename('fullpath')));

opt.dir.raw = fullfile(root_dir, 'inputs', 'ds002799');
opt.dir.input = fullfile(opt.dir.raw, 'derivatives', 'fmriprep');
opt.dir.derivatives = fullfile(root_dir, 'outputs', 'derivatives');

opt.space = {'MNI152NLin2009cAsym'};

opt.subjects = {'292', '302', '307'};

opt.taskName = 'es';

opt.fwhm.func = 8;

%% SMOOTH

% we need to specify where the smoothed data will go
opt.pipeline.type = 'preproc';
opt.dir.preproc = fullfile(opt.dir.derivatives, 'cpp_spm-preproc');

opt = checkOptions(opt);

% copy the preprocessed Nifti images and
opt.query.desc = {'preproc', 'brain'};
opt.query.suffix = {'T1w', 'bold', 'mask'};
opt.query.space = opt.space;
bidsCopyInputFolder(opt);

% then we can smooth
bidsSmoothing(opt);

%% CREATE MODEL
[BIDS, opt] = getData(opt, opt.dir.raw);

createDefaultStatsModel(BIDS, opt);

% we need to edit the model a bit
opt.model.file = fullfile(pwd, 'models', 'model-defaultEs_smdl.json');
bm = BidsModel('file', opt.model.file);

% only focus on the 'es' task
bm.Input.task = {'es'};
bm.Input.space = opt.space;

%% update the run level node

run_lvl_idx = 1;

% add a transformation to add a dummy column of trial type
% because there is none in the events.file
%
% this use the "constant" Transformer
% to add a column with all the same value in each row

bm.Nodes{run_lvl_idx}.Transformations.Transformer = 'cpp_spm';
bm.Nodes{run_lvl_idx}.Transformations.Instructions = {struct('Name', 'Constant', ...
                                                             'Value', 'es', ...
                                                             'Output', 'trial_type')};

% update design matrix and contrasts
% we model the main condition and get a contrast just for this condition

bm.Nodes{run_lvl_idx}.Model.X{end + 1} = 'trial_type.es';
bm.Nodes{run_lvl_idx}.Model.HRF.Variables = {'trial_type.es'};
bm.Nodes{run_lvl_idx}.DummyContrasts.Contrasts =  {'es'};
bm.Nodes{run_lvl_idx} = rmfield(bm.Nodes{run_lvl_idx}, 'Contrasts');

%% update the dataset level node

run_lvl_idx = 3;
bm.Nodes{run_lvl_idx}.GroupBy = {'contrast'};

%% write
bm.write(opt.model.file);

%% run subject level stats
bidspm(opt.dir.raw, opt.dir.derivatives, 'subject', ...
        'participant_label', opt.subjects, ...
        'action', 'stats', ...
        'preproc_dir', opt.dir.preproc, ...
        'model_file', opt.model.file, ...
        'fwhm', opt.fwhm.func);

%% run group level stats
bidspm(opt.dir.raw, opt.dir.derivatives, 'dataset', ...
        'participant_label', opt.subjects, ...
        'action', 'stats', ...
        'preproc_dir', opt.dir.preproc, ...
        'model_file', opt.model.file, ...
        'fwhm', opt.fwhm.func);
