% (C) Copyright 2019 Remi Gau
%
%
% This show how an anat only workflow would look like
%

clear;
clc;

downloadData = true;

run ../../initCppSpm.m;

%% Set options
opt.dataDir = fullfile(fileparts(mfilename('fullpath')), 'outputs', 'raw');
opt.derivativesDir = fullfile(opt.dataDir, '..', 'derivatives', 'cpp_spm-anat');
opt = checkOptions(opt);
saveOptions(opt);

%% Removes previous analysis, gets data and converts it to BIDS
if downloadData

  download_convert_face_rep_ds();

end

%% Run batches
reportBIDS(opt);
bidsCopyRawFolder(opt, 1, 'anat');

bidsSegmentSkullStrip(opt);

% The following do not run on octave for now (because of spmup)
anatomicalQA(opt);
