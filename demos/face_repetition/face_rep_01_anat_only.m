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

% the following "bids app" call will run:
%
% - copies the necessary data from the raw to the derivative folder,
% - runs spatial preprocessing
%
% that are otherwise handled by the bidsCopyInputFolder.m,
% and bidsSpatialPrepro.m workflows
%
% type cpp_spm('action', 'help')
% or see this page: https://cpp-spm.readthedocs.io/en/dev/bids_app_api.html
% for more information on what parameters are obligatory or optional
%

bids_dir = fullfile(fileparts(mfilename('fullpath')), 'outputs', 'raw');

output_dir = fullfile(bids_dir, '..', 'derivatives');

cpp_spm(bids_dir, output_dir, 'subject', ...
        'action', 'preprocess', ...
        'space', {'individual', 'IXI549Space'}, ...
        'anat_only', true);
