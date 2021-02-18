% (C) Copyright 2019 Remi Gau

% creates a ROI in MNI space from the proba atlas
% creates its equivalent in subject space

clear;
clc;

% Smoothing to apply
FWHM = 8;

DownloadData = true;

% URL of the data set to download
% directory with this script becomes the current directory
WD = fileparts(mfilename('fullpath'));

% we add all the subfunctions that are in the sub directories
addpath(genpath(fullfile(WD, '..', '..', 'src')));
addpath(genpath(fullfile(WD, '..', '..', 'lib')));

%% Set options
opt = FaceRep_getOption();

opt.roi.atlas = 'ProbAtlas_v4';
opt.roi.name = 'hMT';
opt.roi.space = {'MNI', 'individual'};

bidsCreateROI(opt);
