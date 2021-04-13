% (C) Copyright 2021 CPP_SPM developers

clear;
clc;

% URL of the data set to download
% URL = https://gin.g-node.org/mwmaclean/CVI-Datalad/src/master/data

run ../../initCppSpm.m;

%% Get Data
opt = Lesion_getOption();

%% Run batches
reportBIDS(opt);

deleteZippedNii = true;
bidsCopyRawFolder(opt, deleteZippedNii, {'anat'});

bidsLesionSegmentation(opt);
