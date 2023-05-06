% Runs smoothing and stats on ds002799 from openneuro
%
% To get the data run (requires datalad):
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

%% Parameters

% directories
bids_dir = fullfile(root_dir, 'inputs', 'ds002799');
fmriprep_dir =  fullfile(bids_dir, 'derivatives', 'fmriprep');
output_dir = fullfile(root_dir, 'outputs', 'derivatives');
preproc_dir = fullfile(output_dir, 'bidspm-preproc');

% the the values below are just examples
subject_label = {'292', '302', '307'};
task = {'es'};
space = {'MNI152NLin2009cAsym'};
fwhm = 6;
verbosity = 3;

%% Smooth

bidspm(fmriprep_dir, output_dir, 'subject', ...
       'action', 'smooth', ...
       'participant_label', subject_label, ...
       'task', task, ...
       'space', space, ...
       'fwhm', fwhm, ...
       'verbosity', verbosity);

%% Create model

% create default model
bidspm(bids_dir, output_dir, 'dataset', ...
       'action', 'default_model', ...
       'task', task, ...
       'space', space, ...
       'verbosity', verbosity);

% we need to edit the model a bit
model_file = fullfile(output_dir, 'models', 'model-defaultEs_smdl.json');
bm = BidsModel('file', model_file);

% update the run level node
run_lvl_idx = 1;
% add a transformation to add a dummy column of trial type
% because there is none in the events.file
%
% this use the "constant" Transformer
% to add a column with all the same value in each row

bm.Nodes{run_lvl_idx}.Transformations.Transformer = 'bidspm';
bm.Nodes{run_lvl_idx}.Transformations.Instructions = {struct('Name', 'Constant', ...
                                                             'Value', 'es', ...
                                                             'Output', 'trial_type')};
% update design matrix and contrasts
% we model the main condition and get a contrast just for this condition
bm.Nodes{run_lvl_idx}.Model.X{end + 1} = 'trial_type.es';
bm.Nodes{run_lvl_idx}.Model.HRF.Variables = {'trial_type.es'};
bm.Nodes{run_lvl_idx}.DummyContrasts.Contrasts =  {'es'};
bm.Nodes{run_lvl_idx} = rmfield(bm.Nodes{run_lvl_idx}, 'Contrasts');

% update the dataset level node
run_lvl_idx = 3;
bm.Nodes{run_lvl_idx}.GroupBy = {'contrast'};

% write
bm.write(model_file);

%% run subject level stats
bidspm(bids_dir, output_dir, 'subject', ...
       'participant_label', subject_label, ...
       'action', 'stats', ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file, ...
       'fwhm', fwhm, ...
       'verbosity', verbosity, ...
       'skip_validation', true);

%% run group level stats
opt.fwhm.contrast = fwhm;

bidspm(bids_dir, output_dir, 'dataset', ...
       'participant_label', subject_label, ...
       'action', 'stats', ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file, ...
       'fwhm', fwhm, ...
       'options', opt, ...
       'verbosity', verbosity, ...
       'skip_validation', true);
