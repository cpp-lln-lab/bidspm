% This script will run the stats on it
% of an fmriprep preprocessed dataset
%
% In general type "bidspm help" in the MATLAB commandet line
% to get more info on the options you can use.
%
%

% (C) Copyright 2022 Remi Gau

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

%% Parameters

% directories
bids_dir = path_to_your_raw_bids_dataset;
fmriprep_dir = path_to_your_fmriprep_dataset;
output_dir = path_where_to_save_the_output;

% the the values below are just examples
subject_label = {'01'};
task = {'auditory'};
space = {'MNI152NLin6Asym'};
fwhm = 8;

%% Copy and smooth
%
% fmriprep data is not smoothed so we need to do that first
% but we copy the required data out of it first
% to not pollute our fmriprep dataset.
%

bidspm(fmriprep_dir, output_dir, 'subject', ...
       'action', 'smooth', ...
       'participant_label', {subject_label}, ...
       'task', {task}, ...
       'space', {space}, ...
       'fwhm', fwhm);

%% STATS

% Create stats model
output_dir = fullfile(WD, 'outputs', 'derivatives');

bidspm(bids_dir, output_dir, 'dataset', ...
       'action', 'default_model', ...
       'space', space, ...
       'ignore', {'contrasts', 'transformations'});

% Run model
model_file = fullfile(output_dir, 'models', 'model-default_smdl.json');

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

bidspm(bids_dir, output_dir, 'subject', ...
       'participant_label', subject_label, ...
       'action', 'stats', ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file, ...
       'space', space, ...
       'fwhm', fwhm, ...
       'options', opt);
