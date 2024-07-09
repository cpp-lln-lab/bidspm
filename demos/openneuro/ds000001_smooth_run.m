% Runs:
% - smoothing of fmriprep data
% - stats at the suject level
%

% (C) Copyright 2020 bidspm developers

clear;
clc;

SMOOTH = true;

addpath(fullfile(pwd, '..', '..'));
bidspm();

% The directory where the data are located
root_dir = fileparts(mfilename('fullpath'));
bids_dir = fullfile(root_dir, 'inputs', 'ds000001');
fmriprep_dir =  fullfile(root_dir, 'inputs', 'ds000001-fmriprep');
output_dir = fullfile(root_dir, 'outputs', 'ds000001', 'derivatives');

participant_label = {'01', '02', '03'};
task = {'balloonanalogrisktask'};
space = {'MNI152NLin2009cAsym'};

%% Copy preprocessed data
if SMOOTH
  bidspm(fmriprep_dir, output_dir, 'subject', ...
         'action', 'smooth', ...
         'participant_label', participant_label, ...
         'task', task, ...
         'space', space, ...
         'verbosity', 3);
end

%% Stats
preproc_dir = fullfile(root_dir, 'outputs', 'ds000001', 'derivatives', 'bidspm-preproc');

model_file = fullfile(root_dir, 'models', 'model-balloonanalogrisktaskDefault_smdl.json');

%% subject level
bidspm(bids_dir, output_dir, 'subject', ...
       'action', 'stats', ...
       'participant_label', participant_label, ...
       'preproc_dir', preproc_dir, ...
       'task', task, ...
       'space', space, ...
       'model_file', model_file);
