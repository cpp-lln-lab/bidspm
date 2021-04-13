% (C) Copyright 2020 CPP_SPM developers

% runDs001168

clear;
clc;

% Smoothing to apply
FWHM = 6;

run ../../initCppSpm.m;

%% Set options
opt = ds001168_getOption();

%% Run batches

reportBIDS(opt);

bidsCopyRawFolder(opt, 1);

bidsCreateVDM(opt);

bidsSTC(opt);

bidsSpatialPrepro(opt);

anatomicalQA(opt);
bidsResliceTpmToFunc(opt);
functionalQA(opt);

bidsSmoothing(FWHM, opt);

% Not implemented yet
% bidsFFX('specifyAndEstimate', opt, FWHM);
% bidsFFX('contrasts', opt, FWHM);
% bidsResults(opt, FWHM, []);
