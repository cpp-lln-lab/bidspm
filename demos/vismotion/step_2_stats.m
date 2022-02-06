% (C) Copyright 2019 CPP_SPM developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
cpp_spm('init');

%% Using default model
% This part let CPP SPM create a default BIDS stats model
% and we will compute the group results using this.

% FYI: not ideal so you can also see in "get_option_stats"
%      how to use a better one

opt = get_option_stats('subject');

%% Subject level Univariate
bidsFFX('specifyAndEstimate', opt);
bidsFFX('contrasts', opt);

bidsResults(opt);

%% Group level univariate
bidsRFX('smoothContrasts', opt);
bidsRFX('meananatandmask', opt);

opt = get_option_stats('dataset');
bidsRFX('rfx', opt);
bidsResults(opt);
