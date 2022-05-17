% (C) Copyright 2021 CPP_SPM developers

clear;
clc;

% This script will will run
% 1) lesion segmentation,
% 2) lesion abnormalities detection and
% 3) lesion overlapmap adapted from the ALI toolbox (SPM.)

% URL of the data set to download
% URL = https://gin.g-node.org/mwmaclean/CVI-Datalad/src/master/data

addpath(fullfile(pwd, '..', '..'));
cpp_spm();

%% Set options
opt = lesion_get_option();

%% Run batches
reportBIDS(opt);

bidsCopyInputFolder(opt);

% Step 1: segmentation
bidsLesionSegmentation(opt);

% % Step 2: lesion abnormalities
bidsLesionAbnormalitiesDetection(opt);

% % Step 3: overlap map
% bidsLesionOverlapMap(opt)
