% (C) Copyright 2020 bidspm developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

% The directory where the data are located
root_dir = fileparts(mfilename('fullpath'));
bids_dir = fullfile(root_dir, 'inputs', 'ds001734');
output_dir = fullfile(root_dir, 'outputs', 'ds001734', 'derivatives');

% to say which T1w file should be used as reference
opt.bidsFilterFile.t1w.ses = 'retest';

%% Preprocessing

bidspm(bids_dir, output_dir, 'subject', ...
       'participant_label', {'01', '02'}, ...
       'action', 'smooth', ...
       'task', {'MGT'}, ...
       'ignore', {'unwarp', 'slicetiming'}, ...
       'space', {'IXI549Space'}, ...
       'options', opt);

%% Statistics

preproc_dir = fullfile(root_dir, 'outputs', 'ds000114', 'derivatives', 'bidspm-preproc');
model_file = fullfile(root_dir, 'models', 'model-ds000114_desc-linebisection_smdl.json');

opt.results.nodeName = 'subject_level';
opt.results.name = {'Correct_Task'
                    'Incorrect_Task'
                    'No_Response_Task'
                    'Response_Control'
                    'No_Response_Control'};

%% Subject level analysis

bidspm(bids_dir, output_dir, 'subject', ...
       'action', 'stats', ...
       'participant_label', {'01', '02'}, ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file, ...
       'options', opt);

%% dataset level analysis

opt.results.nodeName = 'dataset_level';
opt.results.k = 10;

bidspm(bids_dir, output_dir, 'dataset', ...
       'action', 'stats', ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file, ...
       'concatenate', true, ...
       'options', opt);
