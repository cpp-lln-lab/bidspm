% (C) Copyright 2019 Remi Gau

% This script will download the dataset from the FIL for the block design SPM tutorial
% and will run the basic preprocessing, FFX and contrasts on it.
%
% Results might be a bit different from those in the manual as some
% default options are slightly different in this pipeline
% (e.g use of FAST instead of AR(1), motion regressors added)

clear;
clc;

% Smoothing to apply
FWHM = 6;

downloadData = true;

run ../../initCppSpm.m;

%% Set options
opt = moae_get_option();

download_moae_ds(downloadData);

%% Run batches
reportBIDS(opt);
bidsCopyRawFolder(opt, 1);

% In case you just want to run segmentation and skull stripping
% bidsSegmentSkullStrip(opt);
%
% NOTE: skull stripping is also included in 'bidsSpatialPrepro'

bidsSTC(opt);

bidsSpatialPrepro(opt);

% The following do not run on octave for now (because of spmup)
anatomicalQA(opt);
bidsResliceTpmToFunc(opt);
functionalQA(opt);

bidsSmoothing(FWHM, opt);

% The following crash on CI
WD = pwd;
bidsFFX('specifyAndEstimate', opt, FWHM);
cd(WD);
bidsFFX('contrasts', opt, FWHM);
cd(WD);
bidsResults(opt, FWHM);
cd(WD);
