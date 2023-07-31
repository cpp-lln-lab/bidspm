% (C) Copyright 2020 bidspm developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

% The directory where the data are located
root_dir = fileparts(mfilename('fullpath'));
bids_dir = fullfile(root_dir, 'inputs', 'ds000001');
output_dir = fullfile(root_dir, 'outputs', 'ds000001', 'derivatives');

participant_label = {'01', '02', '03'};

%% Preprocessing
parfor i_participant = 1:numel(participant_label)
  bidspm(bids_dir, output_dir, 'subject', ...
         'participant_label', participant_label(i_participant), ...
         'action', 'preprocess', ...
         'task', {'balloonanalogrisktask'}, ...
         'space', {'IXI549Space'});
end

%% Stats
preproc_dir = fullfile(root_dir, 'outputs', 'ds000001', 'derivatives', 'bidspm-preproc');

model_file = fullfile(root_dir, 'models', 'model-balloonanalogrisktaskDefault_smdl.json');

%% subject level
parfor i_participant = 1:numel(participant_label)
  bidspm(bids_dir, output_dir, 'subject', ...
         'action', 'stats', ...
         'participant_label', participant_label(i_participant), ...
         'preproc_dir', preproc_dir, ...
         'space', {'IXI549Space'}, ...
         'model_file', model_file);
end

%% dataset level
bidspm(bids_dir, output_dir, 'dataset', ...
       'action', 'stats', ...
       'preproc_dir', preproc_dir, ...
       'space', {'IXI549Space'}, ...
       'model_file', model_file);
