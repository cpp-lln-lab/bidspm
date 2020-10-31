% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

% runDs001168

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
opt = ds001168_getOption();

% the line below allows to run preprocessing in "native" space.
% - use realign and unwarp
% - don't do normalization
opt.space = 'individual';

checkDependencies();

%% Run batches

reportBIDS(opt);

bidsCopyRawFolder(opt, 1);

bidsCreateVDM(opt);

bidsSTC(opt);

bidsSpatialPrepro(opt);

anatomicalQA(opt);
bidsResliceTpmToFunc(opt);
functionalQA(opt);
%
% bidsSmoothing(FWHM, opt);
%
% bidsFFX('specifyAndEstimate', opt, FWHM);
% bidsFFX('contrasts', opt, FWHM);
% bidsResults(opt, FWHM, []);
