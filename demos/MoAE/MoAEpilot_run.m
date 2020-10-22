% (C) Copyright 2019 Remi Gau

% This script will download the dataset from the FIL for the block design SPM
% tutorial and will run the basic preprocessing, FFX and contrasts on it.
% Results might be a bit different from those in the manual as some
% default options are slightly different in this pipeline (e.g use of FAST
% instead of AR(1), motion regressors added)

clear;
clc;

% Smoothing to apply
FWHM = 6;

% URL of the data set to download
URL = 'http://www.fil.ion.ucl.ac.uk/spm/download/data/MoAEpilot/MoAEpilot.bids.zip';

% directory with this script becomes the current directory
WD = fileparts(mfilename('fullpath'));

% we add all the subfunctions that are in the sub directories
addpath(fullfile(WD, '..'));
addpath(genpath(fullfile(WD, '..', 'src')));
addpath(genpath(fullfile(WD, '..', 'lib')));

%% Set options
opt = MoAEpilot_getOption();

% Uncomment the line below to run preprocessing in "native" space.
% - use realign and unwarp
% - don't do normalization
% opt.space = 'T1w';

%% Get data
fprintf('%-40s:', 'Downloading dataset...');
urlwrite(URL, 'MoAEpilot.zip');
unzip('MoAEpilot.zip', fullfile(WD, 'output'));

checkDependencies();

%% Run batches
isMVPA = 0;

reportBIDS(opt);
bidsCopyRawFolder(opt, 1);
bidsSTC(opt);
bidsSpatialPrepro(opt);

% bidsSmoothing(FWHM, opt);
% bidsFFX('specifyAndEstimate', opt, FWHM, isMVPA);
% bidsFFX('contrasts', opt, FWHM, isMVPA);
% bidsResults(opt, FWHM, [], isMVPA);
