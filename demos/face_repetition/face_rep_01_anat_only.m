%
% This show how an anat only pipeline would look like.
%
% **Download**
%
% -  downloads and BIDSify the dataset from the FIL website
%
% **Preprocessing**
%
%   - copies the necessary data from the raw to the derivative folder,
%   - runs spatial preprocessing
%
% those are otherwise handled by the workflows:
%
%   - ``bidsCopyInputFolder.m``
%   - ``bidsSpatialPrepro.m``
%
% type `bidspm help` or `bidspm('action', 'help')`
% or see this page: https://bidspm.readthedocs.io/en/dev/bids_app_api.html
% for more information on what parameters are obligatory or optional
%
%
% (C) Copyright 2022 Remi Gau

clear;
clc;

downloadData = true;

addpath(fullfile(pwd, '..', '..'));

%% Gets data and converts it to BIDS
if downloadData
  bidspm();
  download_face_rep_ds(downloadData);
end

bids_dir = fullfile(fileparts(mfilename('fullpath')), 'outputs', 'raw');

output_dir = fullfile(bids_dir, '..', 'derivatives');

bidspm(bids_dir, output_dir, 'subject', ...
       'action', 'preprocess', ...
       'space', {'individual', 'IXI549Space'}, ...
       'anat_only', true);
