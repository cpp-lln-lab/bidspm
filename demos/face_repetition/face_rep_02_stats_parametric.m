% This script will run the FFX and contrasts
% on the the face repetition dataset from SPM.
%
% Results might be a bit different from those in the manual as some
% default options are slightly different in this pipeline (e.g use of FAST
% instead of AR(1)...)
%
% (C) Copyright 2019 Remi Gau

% TODO
% - create the contrast similar to the tuto

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
cpp_spm();

opt = face_rep_get_option_results();

opt.model.file = spm_file(opt.model.file, 'basename', 'model-faceRepetitionParametric_smdl');
opt.model.bm = BidsModel('file', opt.model.file);

bidsFFX('specifyAndEstimate', opt);
% bidsFFX('contrasts', opt);

% bidsResults(opt);
