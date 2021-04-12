% (C) Copyright 2019 Remi Gau

% creates a ROI in MNI space from the proba atlas
% creates its equivalent in subject space

run face_rep_anat.m;

opt = face_rep_get_option();

opt.roi.atlas = 'wang';
opt.roi.name = {'V1v', 'V1d'};
opt.roi.space = {'MNI', 'individual'};

opt.dir.stats = fullfile(opt.dataDir, '..', 'derivatives', 'cpp_spm-stats');

bidsCreateROI(opt);

opt.glm.roibased.do = true;

bidsRoiBasedGLM(opt);
