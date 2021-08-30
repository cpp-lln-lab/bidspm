% (C) Copyright 2019 Remi Gau

clear;

opt = tsnr_get_option();

opt.pipeline.type = 'preproc';
opt = checkOptions(opt);

opt.roi.name = {'Left Thalamus Proper'};

bidsCreateROI(opt);
