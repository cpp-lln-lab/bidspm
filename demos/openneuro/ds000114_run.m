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

bidsCopyInputFolder(opt, 1);

bidsSTC(opt);

bidsSpatialPrepro(opt);

anatomicalQA(opt);
bidsResliceTpmToFunc(opt);
functionalQA(opt);

bidsSmoothing(FWHM, opt);

%% Run level analysis: as for MVPA

bidsFFX('specifyAndEstimate', opt, FWHM);
bidsFFX('contrasts', opt, FWHM);

bidsConcatBetaTmaps(opt, FWHM, false, false);

%% Subject level analysis: for regular univariate

opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                          'models', ...
                          'model-ds000114-linebisection_smdl.json');

bidsFFX('specifyAndEstimate', opt, FWHM);

opt.result.Steps(1) = struct( ...
                             'Level',  'subject', ...
                             'Contrasts', struct( ...
                                                 'Name', 'Correct_Task', ... % has to match
                                                 'Mask', false, ...
                                                 'MC', 'FWE', ... FWE, none, FDR
                                                 'p', 0.05, ...
                                                 'k', 0));

bidsFFX('contrasts', opt, FWHM);
bidsResults(opt, FWHM);

bidsRFX('smoothContrasts', opt, FWHM, conFWHM);
bidsRFX('RFX', opt, FWHM, conFWHM);

% WIP: group level results
% bidsResults(opt, FWHM);
