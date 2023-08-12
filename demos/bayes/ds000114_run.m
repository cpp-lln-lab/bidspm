% (C) Copyright 2023 bidspm developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

% set to false to not re run the smoothing
SMOOTH = true;

% set to false to not re run the model specification
FIRST_LEVEL = true;

VERBOSITY = 1;

FWHM = 8;

% to run on fewer subjects
TESTING = true;

% The directory where the data are located
root_dir = fileparts(mfilename('fullpath'));
bids_dir = fullfile(root_dir, 'inputs', 'ds000114');
fmriprep_dir = fullfile(root_dir, 'inputs', 'ds000114-fmriprep');
output_dir = fullfile(root_dir, 'outputs', 'ds000114', 'derivatives');

models_dir = fullfile(root_dir, 'models');

participant_label = {'[0-9]*'}; %#ok<*NASGU>
if TESTING
  participant_label = {'^0[12]$'};
end

%% Smooth
if SMOOTH
  % only need to smooth the functional data
  opt.query.modality = {'func'};
  bidspm(fmriprep_dir, output_dir, 'subject', ...
         'action', 'smooth', ...
         'participant_label', participant_label, ...
         'task', {'overtverbgeneration'}, ...
         'space', {'MNI152NLin2009cAsym'}, ...
         'fwhm', FWHM, ...
         'verbosity', VERBOSITY, ...
         'options', opt); %#ok<*UNRCH>
end

%% create models from a default one

default_model_file = fullfile(models_dir, 'default_model.json');

multiverse.motion = {'none', 'basic', 'full'};
multiverse.scrub = {false, true};
multiverse.wm_csf = {'none', 'basic', 'full'};
multiverse.non_steady_state = {false, true};

if TESTING
  multiverse.motion = {'none', 'basic'};
  multiverse.wm_csf = {'none'};
  multiverse.non_steady_state = {false};
end

createModelFamilies(default_model_file, multiverse, models_dir);

%% Statistics
preproc_dir = fullfile(output_dir, 'bidspm-preproc');

%% Subject level analysis
if FIRST_LEVEL

  bidspm(bids_dir, output_dir, 'subject', ...
         'participant_label', participant_label, ...
         'action', 'specify_only', ...
         'preproc_dir', preproc_dir, ...
         'model_file', models_dir, ...
         'fwhm', FWHM, ...
         'skip_validation', true, ...
         'use_dummy_regressor', true, ...
         'verbosity', VERBOSITY);

end

bidspm(bids_dir, output_dir, 'subject', ...
       'action', 'bms', ...
       'participant_label', participant_label, ...
       'models_dir', models_dir, ...
       'fwhm', FWHM, ...
       'skip_validation', true, ...
       'verbosity', VERBOSITY);
