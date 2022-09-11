% (C) Copyright 2021 bidspm developers

clear;
clc;

% This script will will run
% 1) lesion segmentation,
% 2) lesion abnormalities detection and
% 3) lesion overlapmap adapted from the ALI toolbox (SPM.)

% URL of the data set to download
% URL = https://gin.g-node.org/mwmaclean/CVI-Datalad/src/master/data

addpath(fullfile(pwd, '..', '..'));
bidspm();

%% Set options
[opt, opt2] = lesion_get_option();

%% Run batches
% bidsCopyInputFolder(opt);
% bidsCopyInputFolder(opt2);

%% Step 1: segmentation
% bidsLesionSegmentation(opt);
% bidsLesionSegmentation(opt2);

%% Step 2: lesion abnormalities
bidsLesionAbnormalitiesDetection(opt, opt2);

% % Step 3: overlap map
% bidsLesionOverlapMap(opt)
