%
% This show how an anat only pipeline would look like.
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
        'space', {'individual', 'IXI549Space'}, ...
        'anat_only', true);
