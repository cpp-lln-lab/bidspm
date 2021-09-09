%
% This script will download the face repetition dataset from SPM
% and will run the basic preprocessing.
%
%
% (C) Copyright 2019 Remi Gau

clear;
clc;

downloadData = false;

run ../../initCppSpm.m;

opt = face_rep_get_option();

%% Removes previous analysis, gets data and converts it to BIDS
if downloadData

  download_convert_face_rep_ds();

end

% reportBIDS(opt);

bidsCopyInputFolder(opt);

bidsSTC(opt);

bidsSpatialPrepro(opt);

anatomicalQA(opt);

bidsResliceTpmToFunc(opt);

% DEBUG
% functionalQA(opt);

bidsSmoothing(opt);
