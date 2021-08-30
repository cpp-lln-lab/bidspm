% (C) Copyright 2019 Remi Gau

clear;
clc;

download_data = false;

run ../../initCppSpm.m;

opt = tsnr_get_option();

opt.pipeline.type = 'preproc';

bidsCopyInputFolder(opt);

bidsSpatialPrepro(opt);
