% (C) Copyright 2019 bidspm developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

this_dir = fileparts(mfilename('fullpath'));
model_file = fullfile(this_dir, 'models', 'model-visMotionLoc_smdl.json');
root_dir = fullfile(this_dir, '..', '..', '..', '..');
bids_dir = fullfile(root_dir, 'inputs', 'raw');
output_dir = fullfile(root_dir, 'outputs', 'derivatives');
preproc_dir = fullfile(root_dir, 'outputs', 'derivatives', 'cpp_spm-preproc');

% TODO via BIDS api
% bidsRFX('meananatandmask', opt);

%% subject level

results.nodeName = 'subject_level';
results.name = {'VisMot', 'VisStat', 'VisMot_gt_VisStat'};
results.png = true();
results.csv = true();
results.montage.do = true();
results.montage.slices = -4:2:16;
results.montage.orientation = 'axial';
results.montage.background = struct('suffix', 'T1w', ...
                                    'desc', 'preproc', ...
                                    'modality', 'anat');

opt.results = results;

bidspm(bids_dir, output_dir, 'subject', ...
        'action', 'stats', ...
        'preproc_dir', preproc_dir, ...
        'model_file', model_file, ...
        'options', opt);

%% dataset level

opt.results = struct('nodeName',  'dataset_level', ...
                     'name', {{'VisMot_gt_VisStat'}}, ...
                     'Mask', false, ...
                     'MC', 'none', ...
                     'p', 0.05, ...
                     'k', 10, ...
                     'NIDM', true);

bidspm(bids_dir, output_dir, 'dataset', ...
        'action', 'stats', ...
        'preproc_dir', preproc_dir, ...
        'model_file', model_file, ...
        'options', opt);
