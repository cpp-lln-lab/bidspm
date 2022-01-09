%
% Creates a ROI in MNI space from the retinotopic probablistic atlas.
%
% Creates its equivalent in subject space (inverse normalization).
%
% Then uses marsbar to run a ROI based GLM
%
% (C) Copyright 2019 Remi Gau

clear;
close all;
clc;

try
  run ../../initCppSpm.m;
catch
end

opt = face_rep_get_option_results();

opt.roi.atlas = 'wang';
opt.roi.name = {'V1v', 'V1d'};
opt.roi.space = {'individual'};

% bidsCreateROI(opt);

opt.glm.roibased.do = true;
opt.space = 'individual';

bidsRoiBasedGLM(opt);
