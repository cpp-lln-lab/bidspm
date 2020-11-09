% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

clear;
clc;

% Directory with this script becomes the current directory
pth = fileparts(mfilename('fullpath'));

% We add all the subfunctions that are in the sub directories
addpath(genpath(fullfile(pth, '..', '..', 'src')));
addpath(genpath(fullfile(pth, '..', '..', 'lib')));

%%Run batches

optSource = getOptionSource();

% Single volumes to 4D volumes conversion + remove n dummies
convert3Dto4D(optSource);
