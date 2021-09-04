%
% Creates a ROI in MNI space from the retinotopic probablistic atlas.
%
% Creates its equivalent in subject space (inverse normalization).
%
% Then uses marsbar to run a ROI based GLM
%
% (C) Copyright 2019 Remi Gau

clear;
clc;

run ../../initCppSpm.m;

opt = face_rep_get_option_results();

opt.roi.atlas = 'wang';
opt.roi.name = {'V1v', 'V1d'};
opt.roi.space = {'MNI', 'individual'};

opt.dir.stats = fullfile(opt.dir.raw, '..', 'derivatives', 'cpp_spm-stats');

bidsCreateROI(opt);

opt.glm.roibased.do = true;

bidsRoiBasedGLM(opt);
