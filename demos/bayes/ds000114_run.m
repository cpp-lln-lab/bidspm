% (C) Copyright 2023 bidspm developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

% set to false to not re run the smoothing
SMOOTH = false;

% set to false to not re run the model specification
FIRST_LEVEL = true;

VERBOSITY = 2;

FWHM = 8;

TESTING = true;

% The directory where the data are located
root_dir = fileparts(mfilename('fullpath'));
bids_dir = fullfile(root_dir, 'inputs', 'ds000114');
fmriprep_dir = fullfile(root_dir, 'inputs', 'ds000114-fmriprep');
output_dir = fullfile(root_dir, 'outputs', 'ds000114', 'derivatives');

models_dir = fullfile(root_dir, 'models');

participant_label = {'[0-9]*'};
if TESTING
  participant_label = {'^0[12]$'};
end

%% Smooth
if SMOOTH
  bidspm(fmriprep_dir, output_dir, 'subject', ...
         'action', 'smooth', ...
         'participant_label', participant_label, ...
         'task', {'overtverbgeneration'}, ...
         'space', {'MNI152NLin2009cAsym'}, ...
         'fwhm', FWHM, ...
         'verbosity', VERBOSITY); %#ok<*UNRCH>
end

%% Statistics
preproc_dir = fullfile(output_dir, 'bidspm-preproc');

%% Subject level analysis
if FIRST_LEVEL

  opt.glm.useDummyRegressor = true;

  bidspm(bids_dir, output_dir, 'subject', ...
         'participant_label', participant_label, ...
         'action', 'specify_only', ...
         'preproc_dir', preproc_dir, ...
         'model_file', models_dir, ...
         'fwhm', FWHM, ...
         'skip_validation', true, ...
         'verbosity', VERBOSITY, ...
         'options', opt);

end

bidspm(bids_dir, output_dir, 'subject', ...
       'action', 'bms', ...
       'participant_label', participant_label, ...
       'models_dir', models_dir, ...
       'fwhm', FWHM, ...
       'skip_validation', true, ...
       'verbosity', VERBOSITY);
