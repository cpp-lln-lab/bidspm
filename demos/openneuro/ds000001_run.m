% (C) Copyright 2020 CPP_SPM developers

% runDs00014

clear;
clc;

% Smoothing to apply
FWHM = 6;
conFWHM = 6;

pipeline_name = 'cpp_spm-preprocess';

run ../../initCppSpm.m;

%% Set options
opt = ds000001_get_option();

reportBIDS(opt);

% bidsCopyInputFolder(opt, pipeline_name);
%
% bidsSTC(opt);
%
% bidsSpatialPrepro(opt);
%
% anatomicalQA(opt);
% bidsResliceTpmToFunc(opt);
% functionalQA(opt);
%
% bidsSmoothing(FWHM, opt);

bidsFFX('specifyAndEstimate', opt, FWHM);
bidsFFX('contrasts', opt, FWHM);
bidsResults(opt, FWHM);

bidsRFX('smoothContrasts', opt, FWHM, conFWHM);
bidsRFX('RFX', opt, FWHM, conFWHM);

% WIP: group level results
% bidsResults(opt, FWHM);
