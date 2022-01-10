% (C) Copyright 2019 CPP_SPM developers

clear;
clc;

run ../../initCppSpm.m;

%% Run batches
opt = get_option();

% reportBIDS(opt);

bidsCopyInputFolder(opt, 1);

bidsSTC(opt);
bidsSpatialPrepro(opt);

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
% opt.model.file = fullfile(pwd, ...
%                          'models', ...
%                          'model-motionDecodingMultivariate_smdl.json');
%
% bidsFFX('specifyAndEstimate', opt);
% bidsFFX('contrasts', opt);
% concatBetaImgTmaps(opt);
