% (C) Copyright 2019 CPP_SPM developers

clear;
clc;

run ../../initCppSpm.m;

opt = get_option_preprocess();

reportBIDS(opt);

unzip = true;
bidsCopyInputFolder(opt, unzip);

bidsSTC(opt);

bidsSpatialPrepro(opt);

bidsSmoothing(opt);

