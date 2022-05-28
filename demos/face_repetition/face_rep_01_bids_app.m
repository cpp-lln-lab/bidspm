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

cpp_spm(bids_dir, output_dir, 'subject', ...
        'action', 'preprocess', ...
        'task', {'facerepetition'}, ...
        'space', {'individual', 'IXI549Space'});
