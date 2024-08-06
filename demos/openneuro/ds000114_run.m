% Demo to compare activations across sessions.

% (C) Copyright 2023 bidspm developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

SMOOTH = false;
TASK = 'verbal'; % 'verbal' / 'linebisection'
FWHM = 6;

% The directory where the data are located
root_dir = fileparts(mfilename('fullpath'));
bids_dir = fullfile(root_dir, 'inputs', 'ds000114');
fmriprep_dir = fullfile(root_dir, 'inputs', 'ds000114-fmriprep');
output_dir = fullfile(root_dir, 'outputs', 'ds000114', 'derivatives');

space = {'MNI152NLin2009cAsym'};
participant_label = {'01', '02'};

switch TASK
  case 'linebisection'
    task = {'linebisection'};

    % Some runs have a lot of extra volumes after the session was over
    % so we limit the number of volumes included in each run.
    opt.glm.maxNbVols = 235;

    model_file = fullfile(root_dir, ...
                          'models', ...
                          'model-ds000114_desc-testRetestLineBisection_smdl.json');
  case 'verbal'
    task = {'overtverbgeneration', ...
            'overtwordrepetition', ...
            'covertverbgeneration'};

    opt = struct([]);

    model_file = fullfile(root_dir, ...
                          'models', ...
                          'model-ds000114_desc-testRetestVerbal_smdl.json');
end

%% Smooth
if SMOOTH
  bidspm(fmriprep_dir, output_dir, 'subject', ...
         'participant_label', participant_label, ...
         'action', 'smooth', ...
         'task', task, ...
         'space', space, ...
         'fwhm', FWHM, ...
         'verbosity', 3); %#ok<*UNRCH>
end

%% Statistics
preproc_dir = fullfile(output_dir, 'bidspm-preproc');

%% Subject level analysis
bidspm(bids_dir, output_dir, 'subject', ...
       'participant_label', participant_label, ...
       'action', 'stats', ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file, ...
       'roi_atlas', 'hcpex', ...
       'space', space, ...
       'fwhm', FWHM, ...
       'skip_validation', true, ...
       'options', opt, ...
       'verbosity', 3);

%% dataset level analysis
