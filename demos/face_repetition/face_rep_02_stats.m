% This script will run the FFX and contrasts
% on the the face repetition dataset from SPM.
%
% Results might be a bit different from those in the manual as some
% default options are slightly different in this pipeline (e.g use of FAST
% instead of AR(1)...)
%
% (C) Copyright 2019 Remi Gau

% TODO
% - add derivatives to the model
% - compute the relevant contrasts
% - compute motion effect
% - run parametric model

clear;
clc;

try
  run ../../initCppSpm.m;
catch
end

opt = face_rep_get_option_results();

bidsFFX('specifyAndEstimate', opt);
bidsFFX('contrasts', opt);

bidsResults(opt);
