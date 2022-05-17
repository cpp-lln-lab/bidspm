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
cpp_spm();

opt = face_rep_get_option();

%% Removes previous analysis, gets data and converts it to BIDS
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

reportBIDS(opt);

bidsCopyInputFolder(opt);

bidsSTC(opt);

bidsSpatialPrepro(opt);

bidsSmoothing(opt);
