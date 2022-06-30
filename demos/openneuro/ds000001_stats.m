% (C) Copyright 2020 CPP_SPM developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
cpp_spm();

% The directory where the data are located
root_dir = fileparts(mfilename('fullpath'));
bids_dir = fullfile(root_dir, 'inputs', 'ds000001');
output_dir = fullfile(root_dir, 'outputs', 'ds000001', 'derivatives');
preproc_dir = fullfile(root_dir, 'outputs', 'ds000001', 'derivatives', 'cpp_spm-preproc');

model_file = fullfile(root_dir, 'models', 'model-defaultBalloonanalogrisktask_smdl.json');

opt.results.nodeName = 'subject_level';
opt.results.name = 'cash_demean';

cpp_spm(bids_dir, output_dir, 'subject', ...
        'action', 'stats', ...
        'participant_label', {'01', '02'}, ...
        'preproc_dir', preproc_dir, ...
        'model_file', model_file, ...
        'options', opt);

%%
opt.results.nodeName = 'dataset_level';

cpp_spm(bids_dir, output_dir, 'dataset', ...
        'action', 'stats', ...
        'preproc_dir', preproc_dir, ...
        'model_file', model_file, ...
        'options', opt);
