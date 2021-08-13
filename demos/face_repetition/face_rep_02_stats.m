% (C) Copyright 2019 Remi Gau
%
% This script will run the FFX and contrasts
% on the the face repetition dataset from the FIL.
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

run ../../initCppSpm.m;

opt = face_rep_get_option_results();

% The following crash on CI
opt.pipeline.type = 'stats';

bidsFFX('specifyAndEstimate', opt);
bidsFFX('contrasts', opt);

% TODO
% bidsResults(opt);
