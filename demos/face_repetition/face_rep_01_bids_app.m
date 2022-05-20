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

  WD = pwd;

  pth = bids.util.download_ds('source', 'spm', ...
                              'demo', 'facerep', ...
                              'force', true, ...
                              'verbose', true, ...
                              'out_path', fullfile(WD, 'inputs', 'source'));

  % conversion script from bids-matlab
  cd('../../lib/bids-matlab/demos/spm/facerep/code');
  convert_facerep_ds(fullfile(WD, 'inputs', 'source'), ...
                     fullfile(WD, 'outputs', 'raw'));

  cd(WD);

end

%% Preprocessing

bids_dir = fullfile(fileparts(mfilename('fullpath')), 'outputs', 'raw');

output_dir = fullfile(bids_dir, '..', 'derivatives');

cpp_spm(bids_dir, output_dir, 'subject', ...
        'action', 'preprocess', ...
        'task', {'facerepetition'}, ...
        'space', {'individual', 'IXI549Space'});
