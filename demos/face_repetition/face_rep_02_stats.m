% This script will run the FFX and contrasts
% on the the face repetition dataset from SPM.
%
% Results might be a bit different from those in the manual as some
% default options are slightly different in this pipeline (e.g use of FAST
% instead of AR(1)...)
%
% (C) Copyright 2019 Remi Gau

% TODO
% - compute the relevant contrasts
% - compute motion effect
% - run parametric model

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
cpp_spm('init');

opt = face_rep_get_option_results();
opt.space = 'IXI549Space';

bidsFFX('specifyAndEstimate', opt);
bidsFFX('contrasts', opt);

bidsResults(opt);
