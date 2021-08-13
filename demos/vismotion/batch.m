% (C) Copyright 2019 CPP_SPM developers

clear;
clc;

% directory with this script becomes the current directory
WD = fileparts(mfilename('fullpath'));

run ../../initCppSpm.m;

%% Run batches
opt = get_option();

reportBIDS(opt);

bidsCopyInputFolder(opt, 1);
%
% % preprocessing
bidsSTC(opt);
bidsSpatialPrepro(opt);

% Quality control
anatomicalQA(opt);
bidsResliceTpmToFunc(opt);
functionalQA(opt);

bidsSmoothing(opt);

% subject level Univariate
bidsFFX('specifyAndEstimate', opt);
bidsFFX('contrasts', opt);

% group level univariate
bidsRFX('smoothContrasts', opt);

% Not implemented yet
% bidsRFX(action, opt;

% Not implemented yet
% subject level multivariate
% opt.model.file = fuufile(WD, ...
%                          'models', ...
%                          'model-motionDecodingMultivariate_smdl.json');
%
% bidsFFX('specifyAndEstimate', opt);
% bidsFFX('contrasts', opt);
% concatBetaImgTmaps(opt);
