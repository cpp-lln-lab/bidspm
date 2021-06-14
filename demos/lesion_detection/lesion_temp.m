% (C) Copyright 2019 Remi Gau
%
%
% This show how an anat only workflow would look like
%

clear;
clc;

run ../../initCppSpm.m;

%% Set options
opt.dataDir = 'C:\Users\michm\Data\myphdproject\MRI\CVI-DataLad\data';
opt.derivativesDir = fullfile(opt.dataDir, '..', 'derivatives', 'cpp_spm-anat');
opt.parallelize.do = false;
opt = checkOptions(opt);
saveOptions(opt);

%% Run batches
% reportBIDS(opt);
% bidsCopyRawFolder(opt, 1, 'anat');

bidsSegmentSkullStrip(opt);

% The following do not run on octave for now (because of spmup)
anatomicalQA(opt);
