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
opt.dir.raw = fullfile(fileparts(mfilename('fullpath')), 'outputs', 'raw');
opt.dir.derivatives = fullfile(opt.dir.raw, '..', 'derivatives', 'cpp_spm-anat');
opt.query.modality = 'anat';
opt = checkOptions(opt);
saveOptions(opt);

%% Removes previous analysis, gets data and converts it to BIDS
if downloadData

  download_convert_face_rep_ds();

end

%% Run batches
reportBIDS(opt);
bidsCopyInputFolder(opt, 'cpp_spm-anat', true());

bidsSegmentSkullStrip(opt);

anatomicalQA(opt);
