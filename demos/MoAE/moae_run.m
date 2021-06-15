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

opt.pipeline.type = 'preproc';

bidsCopyInputFolder(opt);

% In case you just want to run segmentation and skull stripping
% NOTE: skull stripping is also included in 'bidsSpatialPrepro'
bidsSegmentSkullStrip(opt);

bidsSTC(opt);

bidsSpatialPrepro(opt);

anatomicalQA(opt);
bidsResliceTpmToFunc(opt);
functionalQA(opt);

% create a whole brain functional mean image mask
% so the mask will be in the same resolution/space as the functional images
% one may not need it if they are running bidsFFX
% since it creates a mask.nii by default
opt.skullstrip.mean = 1;
mask = bidsWholeBrainFuncMask(opt);

% smoooth the funcitional images
bidsSmoothing(FWHM, opt);

% The following crash on CI
opt.pipeline.type = 'stats';

% The following crash on Travis CI
bidsFFX('specifyAndEstimate', opt, FWHM);
bidsFFX('contrasts', opt, FWHM);
bidsResults(opt, FWHM);
