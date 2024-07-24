% Show how to denoise resting state data using the GLM
% by removing confounds from the time series
%
% .. warning
%
%   the fieldmap handling is still work in progress
%   and is therefore skipped in this analysis
%

% (C) Copyright 2020 bidspm developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

% The directory where the data are located
root_dir = fileparts(mfilename('fullpath'));
bids_dir = fullfile(root_dir, 'inputs', 'ds001168');
output_dir = fullfile(root_dir, 'outputs', 'ds001168', 'derivatives');

opt.bidsFilterFile.t1w.ses = '1';
opt.bidsFilterFile.bold.acq = 'fullbrain';

opt.query.modality = {'anat', 'func', 'fmap'};

%% Preprocessing

% TODO
% skipping slicetiming for now as there seems to be a problem
% with the slice timing metadata
% (some slice timing values are higher than the computed acquisition time)
% that lead to a crash

bidspm(bids_dir, output_dir, 'subject', ...
       'participant_label', {'01'}, ...
       'action', 'preprocess', ...
       'task', 'rest', ...
       'space', {'IXI549Space'}, ...
       'skip_validation', true, ...
       'ignore', {'slicetiming', 'fieldmaps'}, ...
       'options', opt);

%% denoise with GLM

preproc_dir = fullfile(output_dir, 'bidspm-preproc');
model_file = fullfile(root_dir, 'models', 'model-ds001168_smdl.json');

bidspm(bids_dir, output_dir, 'subject', ...
       'action', 'stats', ...
       'participant_label', {'01'}, ...
       'preproc_dir', preproc_dir, ...
       'skip_validation', true, ...
       'model_file', model_file, ...
       'keep_residuls', true);
