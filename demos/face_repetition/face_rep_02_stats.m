% This script will run the FFX and contrasts on the the face repetition dataset from SPM.
%
% This assumes you have already preprocessed the data with face_rep_01_bids_app.m
%
% Results might be a bit different from those in the manual as some
% default options are slightly different in this pipeline (e.g use of FAST
% instead of AR(1)...)
%
% (C) Copyright 2019 Remi Gau

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
cpp_spm();

bids_dir = fullfile(fileparts(mfilename('fullpath')), 'outputs', 'raw');
output_dir = fullfile(bids_dir, '..', 'derivatives');
preproc_dir = fullfile(output_dir, 'cpp_spm-preproc');

model_file = fullfile(fileparts(mfilename('fullpath')), ...
                      'models', ...
                      'model-faceRepetition_smdl.json');

subject_label = '01';

% Specify the result to show

% 1rst result to show
results = defaultResultsStructure();
results.nodeName = 'run_level';

results.name = 'faces_gt_baseline_1';

% Specify how you want your output
% (all the following are on false by default)
results.png = true();
results.csv = true();
results.threshSpm = true();
results.binary = true();
results.montage.do = true();
results.montage.slices = -26:3:6; % in mm
results.montage.orientation = 'axial';

opt.results(1) = results;

% 2nd result to show
results = defaultResultsStructure();
results.nodeName = 'run_level';
results.name = 'motion';
results.png = true();

opt.results(2) = results;

% this bids app call will run:
%
% - GLM specification + estimation,
% - compute contrasts and
% - show results
%
% that are otherwise handled by the bidsFFX.m and bidsResults.m workflows
%
% type cpp_spm('action', 'help')
% or see this page: https://cpp-spm.readthedocs.io/en/dev/bids_app_api.html
% for more information on what parameters are obligatory or optional
%

cpp_spm(bids_dir, output_dir, 'subject', ...
        'action', 'stats', ...
        'participant_label', {subject_label}, ...
        'preproc_dir', preproc_dir, ...
        'model_file', model_file, ...
        'options', opt);
