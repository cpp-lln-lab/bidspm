%
% .. warning::
%
%   This script assumes you have already preprocessed the data with face_rep_01_bids_app.m
%
% **stats**
%
% This script will run the FFX and contrasts on the the face repetition dataset from SPM.
%
%   - GLM specification + estimation
%   - compute contrasts
%   - show results
%
% that are otherwise handled by the workflows
%
%   - ``bidsFFX.m``
%   - ``bidsResults.m``
%
% .. note::
%
%       Results might be a bit different from those in the SPM manual as some
%       default options are slightly different in this pipeline
%       (e.g use of FAST instead of AR(1), motion regressors added)
%
%
% type `bidspm help` or `bidspm('action', 'help')`
% or see this page: https://bidspm.readthedocs.io/en/stable/bids_app_api.html
% for more information on what parameters are obligatory or optional
%
%
% (C) Copyright 2022 Remi Gau

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

% skipping validation for now
% as raw data is not 100% valid
skip_validation = true;

this_dir = fileparts(mfilename('fullpath'));

bids_dir = fullfile(this_dir, 'outputs', 'raw');
output_dir = fullfile(this_dir, 'outputs', 'derivatives');
preproc_dir = fullfile(output_dir, 'bidspm-preproc');

model_file = fullfile(this_dir, 'models', 'model-faceRepetition_smdl.json');

subject_label = '01';

% this bids app call will run:
%
% - GLM specification + estimation,
% - compute contrasts and
% - show results
%
% that are otherwise handled by the bidsFFX.m and bidsResults.m workflows
%
% type bidspm('action', 'help')
% or see this page: https://bidspm.readthedocs.io/en/stable/bids_app_api.html
% for more information on what parameters are obligatory or optional
%
% The result to show are specified in the model
%
bidspm(bids_dir, output_dir, 'subject', ...
       'action', 'stats', ...
       'participant_label', {subject_label}, ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file, ...
       'options', opt, ...
       'skip_validation', skip_validation);
