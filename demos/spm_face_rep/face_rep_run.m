% (C) Copyright 2019 Remi Gau

% This script will download the face repetition dataset from the FIL
% and will run the basic preprocessing, FFX and contrasts on it.
%
% Results might be a bit different from those in the manual as some
% default options are slightly different in this pipeline (e.g use of FAST
% instead of AR(1), motion regressors added)
%
% TODO
% - add derivatives to the model
% - compute the relevant contrasts
% - compute motion effect
% - run parametric model
%

clear;
clc;

% Smoothing to apply
FWHM = 8;

DownloadData = true;

% URL of the data set to download
% directory with this script becomes the current directory
WD = fileparts(mfilename('fullpath'));

% we add all the subfunctions that are in the sub directories
addpath(genpath(fullfile(WD, '..', '..', 'src')));
addpath(genpath(fullfile(WD, '..', '..', 'lib')));

%% Set options
opt = FaceRep_getOption();

%% Removes previous analysis, gets data and converts it to BIDS
if DownloadData
  try %#ok<*UNRCH>
    rmdir('source', 's');
    rmdir('raw', 's');
  catch
  end

  face_rep_convert2BIDS();

end

%%
checkDependencies();

%% Run batches
reportBIDS(opt);
bidsCopyRawFolder(opt, 1);

bidsSTC(opt);

bidsSpatialPrepro(opt);

% The following do not run on octave for now (because of spmup)
anatomicalQA(opt);
bidsResliceTpmToFunc(opt);

% DEBUG
% functionalQA(opt);

bidsSmoothing(FWHM, opt);

% The following crash on Travis CI
bidsFFX('specifyAndEstimate', opt, FWHM);
bidsFFX('contrasts', opt, FWHM);

%TODO
bidsResults(opt, FWHM);
