% This script will download the dataset from the FIL for the block design SPM tutorial
% and will run the basic preprocessing.
%
% (C) Copyright 2019 Remi Gau

clear;
clc;

download_data = false;
clean = false;

try
  run ../../initCppSpm.m;
catch
end

opt = moae_get_option();

download_moae_ds(download_data, clean);

reportBIDS(opt);

bidsCopyInputFolder(opt);

bidsSpatialPrepro(opt);

bidsResliceTpmToFunc(opt);

% DOES NOT WORK
% functionalQA(opt);

% create a whole brain functional mean image mask
% so the mask will be in the same resolution/space as the functional images
% one may not need it if they are running bidsFFX
% since it creates a mask.nii by default
% NEEDS DEBUGGING
% opt.skullstrip.mean = 0;
% mask = bidsWholeBrainFuncMask(opt);

bidsSmoothing(opt);
