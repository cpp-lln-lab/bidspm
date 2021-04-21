% (C) Copyright 2020 CPP_SPM developers

% runDs00014

clear;
clc;

% Smoothing to apply
FWHM = 6;
conFWHM = 6;

run ../../initCppSpm.m;

%% Set options
opt = ds000114_get_option();

%% Run batches

reportBIDS(opt);

bidsCopyInputFolder(opt);
bidsSTC(opt);

bidsSpatialPrepro(opt);

anatomicalQA(opt);
bidsResliceTpmToFunc(opt);
functionalQA(opt);

bidsSmoothing(FWHM, opt);

%% Run level analysis: as for MVPA
opt.pipeline.type = 'stats';
bidsFFX('specifyAndEstimate', opt, FWHM);
bidsFFX('contrasts', opt, FWHM);

bidsConcatBetaTmaps(opt, FWHM, false, false);

%% Subject level analysis: for regular univariate
opt.pipeline.type = 'stats';
opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                          'models', ...
                          'model-ds000114-linebisection_smdl.json');

bidsFFX('specifyAndEstimate', opt, FWHM);

bidsFFX('contrasts', opt, FWHM);
bidsResults(opt, FWHM);

bidsRFX('smoothContrasts', opt, FWHM, conFWHM);
bidsRFX('RFX', opt, FWHM, conFWHM);

% WIP: group level results
% bidsResults(opt, FWHM);
