% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

clear;
clc;

% URL of the data set to download
% URL = https://gin.g-node.org/mwmaclean/CVI-Datalad/src/master/data

% Directory with this script becomes the current directory (CPP_SPM_dir)
pth = fileparts(mfilename('fullpath'));

% We add all the subfunctions that are in the sub directories (CPP_SPM_dir)
addpath(genpath(fullfile(pth, '..', '..', 'src')));

%
initCppSpm();

%% Set options
opt.taskName = 'rest';

%% Get Data
opt.dataDir = path_to_your_BIDS_data; % todo
opt = checkOptions(opt);
checkDependencies();

%% Run batches
bidsLesionSegmentation(opt);
