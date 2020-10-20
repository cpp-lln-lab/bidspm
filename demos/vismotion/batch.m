% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

clear;
clc;

% directory with this script becomes the current directory
WD = fileparts(mfilename('fullpath'));

% we add all the subfunctions that are in the sub directories
addpath(fullfile(WD, '..'));
addpath(genpath(fullfile(WD, '..', 'src')));
addpath(genpath(fullfile(WD, '..', 'lib')));

%% Run batches
opt = getOption();

checkDependencies();

% copy raw folder into derivatives folder
% BIDS_copyRawFolder(opt, 1)

% preprocessing
% BIDS_STC(opt);
% BIDS_SpatialPrepro(opt);
% BIDS_Smoothing(6, opt);

% subject level Univariate
% BIDS_FFX(1, 6, opt);
% BIDS_FFX(2, 6, opt);

% group level univariate
BIDS_RFX(1, 6, 6);
BIDS_RFX(2, 6, 6);

BIDS_Results(6, 6, opt, 0);

% subject level multivariate
% isMVPA=1;
% BIDS_FFX(1, 6, opt, isMVPA);
% BIDS_FFX(2, 6, opt, isMVPA);
% make4Dmaps(6,opt)
