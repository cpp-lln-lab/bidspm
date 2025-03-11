% This script shows how to display the results of a GLM
% by having on the same image:
%
% - the beta estimates
% - the t statistics
% - ROI contours
%
%

% (C) Copyright 2021 Remi Gau

clear;
close all;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

this_dir = fileparts(mfilename('fullpath'));

opt.pipeline.type = 'stats';

opt.dir.derivatives = fullfile(this_dir, 'outputs', 'derivatives');
opt.dir.preproc = fullfile(opt.dir.derivatives, 'bidspm-preproc');

opt.model.file = fullfile(this_dir, 'models', 'model-MoAE_smdl.json');

opt.subjects = {'01'};

% read the model
opt = checkOptions(opt);

transparentMontage(opt)
