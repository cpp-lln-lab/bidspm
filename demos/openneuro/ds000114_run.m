% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

% runDs00014

clear;
clc;
close all;

% Smoothing to apply
FWHM = 6;

% directory with this script becomes the current directory
WD = fileparts(mfilename('fullpath'));

% we add all the subfunctions that are in the sub directories
addpath(fullfile(WD, '..'));
addpath(genpath(fullfile(WD, '..', 'src')));
addpath(genpath(fullfile(WD, '..', 'lib')));

%% Set options
opt = ds000114_getOption();

% the line below allows to run preprocessing in "native" space.
% - use realign and unwarp
% - don't do normalization
opt.space = 'T1w';

checkDependencies();

%% Run batches
isMVPA = 0;

reportBIDS(opt);

bidsCopyRawFolder(opt, 1);

bidsSTC(opt);

bidsSpatialPrepro(opt);

bidsSmoothing(FWHM, opt);

bidsFFX('specifyAndEstimate', opt, FWHM, isMVPA);
bidsFFX('contrasts', opt, FWHM, isMVPA);
bidsResults(opt, FWHM, [], isMVPA);
