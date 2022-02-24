% (C) Copyright 2020 CPP_SPM developers

% runDs00014

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
cpp_spm('init');

opt = ds000001_preproc_option();

reportBIDS(opt);

bidsCopyInputFolder(opt);

bidsSpatialPrepro(opt);

bidsSmoothing(opt);
