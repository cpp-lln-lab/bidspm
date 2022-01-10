% (C) Copyright 2020 CPP_SPM developers

% runDs00014

clear;
clc;

run ../../initCppSpm.m;

opt = ds000114_get_option();

reportBIDS(opt);

bidsCopyInputFolder(opt);
bidsSTC(opt);

bidsSpatialPrepro(opt);

bidsSmoothing(FWHM, opt);

%% Run level analysis: as for MVPA
opt.pipeline.type = 'stats';
bidsFFX('specifyAndEstimate', opt);
bidsFFX('contrasts', opt);

bidsConcatBetaTmaps(opt, false, false);

%% Subject level analysis: for regular univariate
opt.pipeline.type = 'stats';
opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                          'models', ...
                          'model-ds000114-linebisection_smdl.json');

bidsFFX('specifyAndEstimate', opt);

bidsFFX('contrasts', opt);
bidsResults(opt);

bidsRFX('smoothContrasts', opt);
bidsRFX('RFX', opt);

% WIP: group level results
% bidsResults(opt);
