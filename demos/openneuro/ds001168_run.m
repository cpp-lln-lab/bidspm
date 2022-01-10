% (C) Copyright 2020 CPP_SPM developers

% runDs001168

clear;
clc;

run ../../initCppSpm.m;

opt = ds001168_get_option();

reportBIDS(opt);

bidsCopyInputFolder(opt);

bidsCreateVDM(opt);

bidsSTC(opt);

bidsSpatialPrepro(opt);

bidsSmoothing(FWHM, opt);

% Not implemented yet
% bidsFFX('specifyAndEstimate', opt);
% bidsFFX('contrasts', opt);
% bidsResults(opt);
