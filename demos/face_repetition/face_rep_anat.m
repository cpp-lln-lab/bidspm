%
% This show how an anat only pipeline would look like.
%
% (C) Copyright 2019 Remi Gau

clear;
clc;

downloadData = true;

run ../../initCppSpm.m;

%% Set options
opt.dir.raw = fullfile(fileparts(mfilename('fullpath')), 'outputs', 'raw');
opt.dir.preproc = fullfile(opt.dir.raw, '..', 'derivatives');

opt.pipeline.type = 'preproc';
opt.pipeline.name = 'cpp_spm-anat';
opt.query.modality = 'anat';

opt = checkOptions(opt);

saveOptions(opt);

%% Removes previous analysis, gets data and converts it to BIDS
if downloadData

  download_convert_face_rep_ds();

end

%% Run batches
% reportBIDS(opt);
bidsCopyInputFolder(opt);

bidsSegmentSkullStrip(opt);

anatomicalQA(opt);
