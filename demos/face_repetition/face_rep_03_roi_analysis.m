% (C) Copyright 2019 Remi Gau
%
% creates a ROI in MNI space from the proba atlas
% creates its equivalent in subject space
%

opt = face_rep_get_option_results();

opt.roi.atlas = 'wang';
opt.roi.name = {'V1v', 'V1d'};
opt.roi.space = {'MNI', 'individual'};

opt.dir.stats = fullfile(opt.dir.raw, '..', 'derivatives', 'cpp_spm-stats');

bidsCreateROI(opt);

opt.glm.roibased.do = true;

bidsRoiBasedGLM(opt);
