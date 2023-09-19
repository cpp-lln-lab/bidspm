% (C) Copyright 2023 bidspm developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

VERBOSITY = 0;

FWHM = 8;

% set to false to not re run the smoothing
SMOOTH = true;

% set to false to not re run the model specification
FIRST_LEVEL = true;

% set to false to not compute cross-validated log model evidence
CVLME = true;

% set to true to run on fewer subjects and fewer models
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

%% create models family from a default one

default_model_file = fullfile(models_dir, 'default_model.json');

multiverse.motion = {'none', 'basic', 'full'};
multiverse.scrub = {false, true};
multiverse.wm_csf = {'none', 'basic', 'full'};
multiverse.non_steady_state = {false, true};

if TESTING
  multiverse.motion = {'basic', 'full'};
  multiverse.scrub = {false, true};
  multiverse.non_steady_state = {true};
end

createModelFamilies(default_model_file, multiverse, models_dir);

%% Statistics
preproc_dir = fullfile(output_dir, 'bidspm-preproc');

% Subject level analysis
if FIRST_LEVEL

  % Silence this warning as this dataset has not been slice time corrected.
  warning('OFF', 'setBatchSubjectLevelGLMSpec:noSliceTimingInfoForGlm');

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

% Run bayesian model selection
% 1. MA_model_space:    defines a model space
% 2. MA_cvLME_auto:     computes cross-validated log model evidence
% 3. MS_PPs_group_auto: calculate posterior probabilities from cvLMEs
% 4. MS_BMS_group_auto: perform cross-validated Bayesian model selection
% 5. MS_SMM_BMS:        generate selected models maps from BMS
if CVLME

  bidspm(bids_dir, output_dir, 'subject', ...
         'action', 'bms', ...
         'participant_label', participant_label, ...
         'models_dir', models_dir, ...
         'fwhm', FWHM, ...
         'skip_validation', true, ...
         'verbosity', VERBOSITY);

end

%% Redefine the model space
% note that it must be a subset of the one defined previously
clear multiverse;
delete(fullfile(pwd, 'models', 'model*.json'));

multiverse.motion = {'basic', 'full'};
multiverse.scrub = {false};
multiverse.non_steady_state = {true};

createModelFamilies(default_model_file, multiverse, models_dir);

%%
% Runs a new bayesian model selection
% but rely on CVLME estimated previously
% 1. MA_model_space:    defines a model space
% 2. MS_PPs_group_auto: calculate posterior probabilities from cvLMEs
bidspm(bids_dir, output_dir, 'subject', ...
       'action', 'bms-posterior', ...
       'participant_label', participant_label, ...
       'models_dir', models_dir, ...
       'fwhm', FWHM, ...
       'skip_validation', true, ...
       'verbosity', VERBOSITY);

% 3. MS_BMS_group_auto: perform cross-validated Bayesian model selection
% 4. MS_SMM_BMS:        generate selected models maps from BMS
bidspm(bids_dir, output_dir, 'subject', ...
       'action', 'bms-bms', ...
       'participant_label', participant_label, ...
       'models_dir', models_dir, ...
       'fwhm', FWHM, ...
       'skip_validation', true, ...
       'verbosity', VERBOSITY);
