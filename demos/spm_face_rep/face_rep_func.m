% (C) Copyright 2019 Remi Gau

% This script will download the face repetition dataset from the FIL
% and will run the basic preprocessing, FFX and contrasts on it.
%
% Results might be a bit different from those in the manual as some
% default options are slightly different in this pipeline (e.g use of FAST
% instead of AR(1), motion regressors added)
%
% TODO
% - add derivatives to the model
% - compute the relevant contrasts
% - compute motion effect
% - run parametric model
%

clear;
clc;

FWHM = 6;

downloadData = true;

run ../../initCppSpm.m;

%% Set options
opt = FaceRep_getOption();

%% Removes previous analysis, gets data and converts it to BIDS
if downloadData

  dowload_convert_face_rep_ds();

end

%% Run batches
reportBIDS(opt);
bidsCopyRawFolder(opt, 1);

bidsSTC(opt);

bidsSpatialPrepro(opt);

% The following do not run on octave for now (because of spmup)
anatomicalQA(opt);
bidsResliceTpmToFunc(opt);

% DEBUG
% functionalQA(opt);

bidsSmoothing(FWHM, opt);

% The following crash on Travis CI
bidsFFX('specifyAndEstimate', opt, FWHM);
bidsFFX('contrasts', opt, FWHM);

% TODO
% bidsResults(opt, FWHM);
