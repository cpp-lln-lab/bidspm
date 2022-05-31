%
% This script will download the face repetition dataset from SPM
% and will run the basic preprocessing.
%
%
% (C) Copyright 2019 Remi Gau

clear;
clc;

downloadData = true;

addpath(fullfile(pwd, '..', '..'));

%% Gets data and converts it to BIDS
if downloadData
  cpp_spm();
  download_face_rep_ds(downloadData);
end

%% Preprocessing

bids_dir = fullfile(fileparts(mfilename('fullpath')), 'outputs', 'raw');

output_dir = fullfile(bids_dir, '..', 'derivatives');

subject_label = '01';

% the following "bids app" call will run:
%
% - copies the necessary data from the raw to the derivative folder,
% - runs slice time correction
% - runs spatial preprocessing
%
% that are otherwise handled by the bidsCopyInputFolder.m, bidsSTC.m
% and bidsSpatialPrepro.m workflows
%
% type cpp_spm('action', 'help')
% or see this page: https://cpp-spm.readthedocs.io/en/dev/bids_app_api.html
% for more information on what parameters are obligatory or optional
%

cpp_spm(bids_dir, output_dir, 'subject', ...
        'participant_label', {subject_label}, ...
        'action', 'preprocess', ...
        'task', {'facerepetition'}, ...
        'space', {'individual', 'IXI549Space'});
