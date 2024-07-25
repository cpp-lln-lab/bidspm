% Demo to run a one-way anova across group

% (C) Copyright 2024 bidspm developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

task = 'checkerboard';

% The directory where the data are located
root_dir = fileparts(mfilename('fullpath'));
bids_dir = fullfile(root_dir, 'inputs', 'ds003397');
fmriprep_dir = fullfile(root_dir, 'inputs', 'ds003397-fmriprep');
output_dir = fullfile(root_dir, 'outputs', 'ds003397', 'derivatives');

space = {'MNI152NLin2009cAsym'};
participant_label = {'01', '06', '11', '12'};

%% Copy (& smooth)
% bidspm(fmriprep_dir, output_dir, 'subject', ...
%      'participant_label', participant_label, ...
%      'action', 'smooth', ...
%      'task', task, ...
%      'space', space, ...
%      'fwhm', 0, ...
%      'verbosity', 3);

%% Stats
preproc_dir = fullfile(output_dir, 'bidspm-preproc');

model_file = fullfile(root_dir, ...
                      'models', ...
                      'model-ds003397_smdl.json');

opt.results(1) = defaultResultsStructure();
opt.results(1).nodeName = 'subject_level';
opt.results(1).name = 'flashing checkerboard';

% bidspm(bids_dir, output_dir, 'subject', ...
%        'participant_label', participant_label, ...
%        'action', 'results', ...
%        'preproc_dir', preproc_dir, ...
%        'model_file', model_file, ...
%        'roi_atlas', 'hcpex', ...
%        'space', space, ...
%        'fwhm', 0, ...
%        'skip_validation', true, ...
%        'verbosity', 3, ...
%        'opt', opt);

bidspm(bids_dir, output_dir, 'dataset', ...
       'participant_label', participant_label, ...
       'action', 'stats', ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file, ...
       'roi_atlas', 'hcpex', ...
       'space', space, ...
       'fwhm', 0, ...
       'skip_validation', true, ...
       'verbosity', 3, ...
       'opt', opt);
