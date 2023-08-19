% This script will download the face repetition dataset from SPM
% and will run the basic preprocessing.
%
% **Download**
%
% -  downloads and BIDSify the dataset from the FIL website
%
% **Preprocessing**
%
%   - copies the necessary data from the raw to the derivative folder,
%   - runs slice time correction
%   - runs spatial preprocessing
%
% those are otherwise handled by the workflows:
%
%   - ``bidsCopyInputFolder.m``
%   - ``bidsSTC.m``
%   - ``bidsSpatialPrepro.m``
%
% type `bidspm help` or `bidspm('action', 'help')`
% or see this page: https://bidspm.readthedocs.io/en/stable/bids_app_api.html
% for more information on what parameters are obligatory or optional
%

% (C) Copyright 2022 Remi Gau

clear;
clc;

download_data = false;

% skipping validation for now
% as raw data is not 100% valid
skip_validation = true;

addpath(fullfile(pwd, '..', '..'));

%% Gets data and converts it to BIDS
bidspm();
if download_data
  download_face_rep_ds(download_data);
end

%% Preprocessing

bids_dir = fullfile(fileparts(mfilename('fullpath')), 'outputs', 'raw');

output_dir = fullfile(bids_dir, '..', 'derivatives');

subject_label = '01';

bidspm(bids_dir, output_dir, 'subject', ...
       'participant_label', {subject_label}, ...
       'action', 'preprocess', ...
       'task', 'facerepetition', ...
       'space', {'individual', 'IXI549Space'}, ...
       'skip_validation', skip_validation);
