% (C) Copyright 2020 bidspm developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

SMOOTH = true;
TASK = 'linebisection'; % 'verbal'

% The directory where the data are located
root_dir = fileparts(mfilename('fullpath'));
bids_dir = fullfile(root_dir, 'inputs', 'ds000114');
fmriprep_dir = fullfile(root_dir, 'inputs', 'ds000114-fmriprep');
output_dir = fullfile(root_dir, 'outputs', 'ds000114', 'derivatives');

space = {'MNI152NLin2009cAsym'};
participant_label = {'01'};

switch TASK
  case 'linebisection'
    task = {'linebisection', ...
            'overtverbgeneration', ...
            'covertverbgeneration', ...
            'overtverbgeneration'};
  case 'verbal'
    task = {'overtverbgeneration', ...
            'overtwordrepetition', ...
            'covertverbgeneration'};
end

%% Smooth
if SMOOTH
  bidspm(fmriprep_dir, output_dir, 'subject', ...
         'participant_label', participant_label, ...
         'action', 'smooth', ...
         'task', task, ...
         'space', space, ...
         'fwhm', 8, ...
         'verbosity', 3); %#ok<*UNRCH>
end

%% Statistics
preproc_dir = fullfile(root_dir, 'outputs', 'ds000114', 'derivatives', 'bidspm-preproc');

%% Subject level analysis
% some runs have a lot of extra volumes after the session was over
opt.glm.maxNbVols = 220;

model_file = fullfile(root_dir, 'models', 'model-ds000114_desc-testRetestLineBisection_smdl.json');

bidspm(bids_dir, output_dir, 'subject', ...
       'participant_label', participant_label, ...
       'action', 'stats', ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file, ...
       'roi_atlas', 'hcpex', ...
       'space', space, ...
       'fwhm', 8, ...
       'skip_validation', true, ...
       'options', opt, ...
       'verbosity', 3);

%% dataset level analysis
