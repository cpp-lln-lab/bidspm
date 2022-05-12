% (C) Copyright 2020 CPP_SPM developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
cpp_spm();

opt = ds000001_preproc_option();

% reportBIDS(opt);

% bidsCopyInputFolder(opt);

bidsSpatialPrepro(opt);

% bidsSmoothing(opt);
