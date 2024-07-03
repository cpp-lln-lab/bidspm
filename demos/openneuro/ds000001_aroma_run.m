% Runs:
% - select only the 'AROMA' files from the fMRIprep output
% - stats at the suject level
% - stats at the group level
%

% (C) Copyright 2020 bidspm developers

clear;
clc;

COPY = true;
SUBJECT_LEVEL_DO = true;

addpath(fullfile(pwd, '..', '..'));
bidspm();

% The directory where the data are located
root_dir = fileparts(mfilename('fullpath'));
bids_dir = fullfile(root_dir, 'inputs', 'ds000001');
fmriprep_dir =  fullfile(root_dir, 'inputs', 'ds000001-fmriprep');
output_dir = fullfile(root_dir, 'outputs', 'ds000001', 'derivatives');

participant_label = {'01', '02', '03', '04', '05'};
task = {'balloonanalogrisktask'};
space = {'MNI152NLin6Asym'};

% use bids filter to only include AROMA files
bids_filter_file = struct('bold', struct('modality', 'func', ...
                                         'suffix', 'bold', ...
                                         'desc', {'smoothAROMAnonaggr'}));

%% Copy preprocessed data
if COPY
  bidspm(fmriprep_dir, output_dir, 'subject', ...
         'action', 'copy', ...
         'participant_label', participant_label, ...
         'task', task, ...
         'space', space, ...
         'bids_filter_file', bids_filter_file, ...
         'verbosity', 3);
end

%% Stats
preproc_dir = fullfile(root_dir, 'outputs', 'ds000001', 'derivatives', 'bidspm-preproc');

model_file = fullfile(root_dir, 'models', 'model-balloonanalogrisktaskAroma_smdl.json');

%% subject level
if SUBJECT_LEVEL_DO
  bidspm(bids_dir, output_dir, 'subject', ...
         'action', 'results', ...
         'participant_label', participant_label, ...
         'preproc_dir', preproc_dir, ...
         'model_file', model_file);
end

%% dataset level
bidspm(bids_dir, output_dir, 'dataset', ...
       'action', 'stats', ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file);
