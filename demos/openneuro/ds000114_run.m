% (C) Copyright 2020 bidspm developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

% The directory where the data are located
root_dir = fileparts(mfilename('fullpath'));
bids_dir = fullfile(root_dir, 'inputs', 'ds000114');
output_dir = fullfile(root_dir, 'outputs', 'ds000114', 'derivatives');

% to say which T1w file should be used as reference
opt.bidsFilterFile.t1w.ses = 'retest';

%% Preprocessing

bidspm(bids_dir, output_dir, 'subject', ...
        'participant_label', {'01', '02'}, ...
        'action', 'preprocess', ...
        'task', {'linebisection'}, ...
        'ignore', {'unwarp', 'slicetiming'}, ...
        'space', {'IXI549Space'}, ...
        'options', opt);

%% Statistics

preproc_dir = fullfile(root_dir, 'outputs', 'ds000114', 'derivatives', 'cpp_spm-preproc');
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
        'ignore', {'slicetiming'}, ...
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
        'options', opt);

%%  for MVPA
bidsConcatBetaTmaps(opt, false, false);
