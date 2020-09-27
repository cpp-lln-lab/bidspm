% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

% runDs00014

clear;
clc;

% Smoothing to apply
FWHM = 6;

% directory with this script becomes the current directory
WD = fileparts(mfilename('fullpath'));

% we add all the subfunctions that are in the sub directories
addpath(fullfile(WD, '..'));
addpath(genpath(fullfile(WD, '..', 'src')));
addpath(genpath(fullfile(WD, '..', 'lib')));

%% Set options
opt = ds000001_getOption();

checkDependencies();

%% Run batches
isMVPA = 0;

% bidsCopyRawFolder(opt, 1);
bidsSpatialPrepro(opt);
bidsSmoothing(FWHM, opt);
% bidsFFX('specifyAndEstimate', opt, FWHM, isMVPA);
% bidsFFX('contrasts', opt, FWHM, isMVPA);
% bidsResults(opt, FWHM, [], isMVPA);
