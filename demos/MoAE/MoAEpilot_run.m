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

initCppSpm();

%% Set options
opt = MoAEpilot_getOption();

%% Get data
fprintf('%-10s:', 'Downloading dataset...');
urlwrite(URL, 'MoAEpilot.zip');
fprintf(1, ' Done\n\n');

fprintf('%-10s:', 'Unzipping dataset...');
unzip('MoAEpilot.zip', fullfile(WD, 'output'));
fprintf(1, ' Done\n\n');

%% Run batches
reportBIDS(opt);
bidsCopyRawFolder(opt, 1);

% In case you just want to run segmentation and skull stripping
% Skull stripping is also included in 'bidsSpatialPrepro'
% bidsSegmentSkullStrip(opt);

bidsSTC(opt);

bidsSpatialPrepro(opt);

% The following do not run on octave for now (because of spmup)
anatomicalQA(opt);
bidsResliceTpmToFunc(opt);
functionalQA(opt);

bidsSmoothing(FWHM, opt);

% The following crash on Travis CI
% bidsFFX('specifyAndEstimate', opt, FWHM);
% bidsFFX('contrasts', opt, FWHM);
% bidsResults(opt, FWHM);
