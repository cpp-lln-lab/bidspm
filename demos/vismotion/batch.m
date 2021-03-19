% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

clear;
clc;

% directory with this script becomes the current directory
WD = fileparts(mfilename('fullpath'));

run ../../initCppSpm.m;

%% Run batches
opt = getOption();

reportBIDS(opt);

bidsCopyRawFolder(opt, 1);
%
% % preprocessing
bidsSTC(opt);
bidsSpatialPrepro(opt);

% Quality control
anatomicalQA(opt);

% Not implemented yet
% bidsResliceTpmToFunc(opt);
% functionalQA(opt);

funcFWHM = 6;
bidsSmoothing(funcFWHM, opt);

% subject level Univariate
bidsFFX('specifyAndEstimate', opt, funcFWHM);
bidsFFX('contrasts', opt, funcFWHM);

% group level univariate
conFWHM = 6;
bidsRFX('smoothContrasts', opt, funcFWHM, conFWHM);

% Not implemented yet
% bidsRFX(action, opt, funcFWHM, conFWHM);

% Not implemented yet
% subject level multivariate
% opt.model.file = fuufile(WD, ...
%                          'models', ...
%                          'model-motionDecodingMultivariate_smdl.json');
%
% bidsFFX('specifyAndEstimate', opt, funcFWHM);
% bidsFFX('contrasts', opt, funcFWHM);
% concatBetaImgTmaps(funcFWHM, opt);
