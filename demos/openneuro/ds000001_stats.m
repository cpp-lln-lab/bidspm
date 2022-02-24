% (C) Copyright 2020 CPP_SPM developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
cpp_spm('init');

opt = ds000001_stats_option();

bidsFFX('specifyAndEstimate', opt);
bidsFFX('contrasts', opt);
bidsResults(opt);

bidsRFX('smoothContrasts', opt);
bidsRFX('RFX', opt);
bidsResults(opt);
