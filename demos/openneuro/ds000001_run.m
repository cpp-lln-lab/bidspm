% (C) Copyright 2020 CPP_SPM developers

% runDs00014

clear;
clc;

run ../../initCppSpm.m;

opt = ds000001_get_option();

reportBIDS(opt);

bidsCopyInputFolder(opt);

bidsSegmentSkullStrip(opt);

bidsSTC(opt);

bidsSpatialPrepro(opt);

bidsSmoothing(opt);

opt.pipeline.type = 'stats';

bidsFFX('specifyAndEstimate', opt);
bidsFFX('contrasts', opt);
bidsResults(opt);

bidsRFX('smoothContrasts', opt);
bidsRFX('RFX', opt);

% WIP: group level results
% bidsResults(opt);
