% This script will run the FFX and contrasts on it of the MoAE dataset
% using the fmriprep preprocessed data
%
%
% (C) Copyright 2019 Remi Gau

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
cpp_spm();

download_data = true;
download_moae_ds(download_data);

opt = moae_get_option_fmriprep_preproc();

bidsCopyInputFolder(opt);

bidsSmoothing(opt);

opt = moae_get_option_fmriprep_stats();

bidsFFX('specifyAndEstimate', opt);
bidsFFX('contrasts', opt);
bidsResults(opt);
