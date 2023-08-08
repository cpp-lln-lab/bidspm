% (C) Copyright 2023 bidspm developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

SMOOTH = true;

% The directory where the data are located
root_dir = fileparts(mfilename('fullpath'));
bids_dir = fullfile(root_dir, 'inputs', 'ds000114');
fmriprep_dir = fullfile(root_dir, 'inputs', 'ds000114-fmriprep');
output_dir = fullfile(root_dir, 'outputs', 'ds000114', 'derivatives');

models_dir = fullfile(root_dir, 'models');

%% Smooth
if SMOOTH
  bidspm(fmriprep_dir, output_dir, 'subject', ...
         'action', 'smooth', ...
         'task', {'linebisection'}, ...
         'fwhm', 8, ...
         'verbosity', 3); %#ok<*UNRCH>
end

%% Statistics
preproc_dir = fullfile(output_dir, 'bidspm-preproc');

%% Subject level analysis

% {'modelSpace', 'cvLME', 'posterior', 'BMS'}

bidspm(bids_dir, output_dir, 'subject', ...
       'participant_label', participant_label, ...
       'action', 'modelSpace', ...
       'preproc_dir', preproc_dir, ...
       'models_dir', models_dir, ...
       'fwhm', 8, ...
       'skip_validation', true, ...
       'verbosity', 3);
