%
% Analysis of the NARPS dataset
%

% (C) Copyright 2022 bidspm developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

% The directory where the data are located
root_dir = fileparts(mfilename('fullpath'));
bids_dir = fullfile(root_dir, 'inputs', 'ds001734');
fmriprep_dir =  fullfile(root_dir, 'inputs', 'ds001734-fmriprep');
output_dir = fullfile(root_dir, 'outputs', 'ds001734', 'derivatives');

subject_label = {'001'};
task = {'MGT'};
space = {'MNI152NLin2009cAsym'};

bidspm(fmriprep_dir, output_dir, 'subject', ...
       'action', 'smooth', ...
       'participant_label', subject_label, ...
       'task', task, ...
       'space', space, ...
       'fwhm', 8);

%% Statistics

preproc_dir = fullfile(root_dir, 'outputs', 'ds001734', 'derivatives', 'bidspm-preproc');
model_file = fullfile(root_dir, 'models', 'model-narps_desc-U26C_smdl.json');

%% Subject level analysis
bidspm(bids_dir, output_dir, 'subject', ...
       'action', 'stats', ...
       'participant_label', subject_label, ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file, ...
       'ignore', {'slice_timing'}, ...
       'skip_validation', true, ...
       'verbosity', 1, ...
       'space', space, ...
       'fwhm', 8);
