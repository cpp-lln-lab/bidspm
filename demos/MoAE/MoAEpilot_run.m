% (C) Copyright 2019 Remi Gau

% This script will download the dataset from the FIL for the block design SPM
% tutorial and will run the basic preprocessing, FFX and contrasts on it.
% Results might be a bit different from those in the manual as some
% default options are slightly different in this pipeline (e.g use of FAST
% instead of AR(1), motion regressors added)

clear;
clc;

% Smoothing to apply
FWHM = 6;

downloadData = true;

run ../../initCppSpm.m;

%% Set options
opt = MoAEpilot_getOption();

dowload_MoAE_ds(downloadData);

%% Run batches
reportBIDS(opt);
bidsCopyRawFolder(opt, 1);

% In case you just want to run segmentation and skull stripping
%
% bidsSegmentSkullStrip(opt);
%
% NOTE: skull stripping is also included in 'bidsSpatialPrepro'

bidsSTC(opt);

bidsSpatialPrepro(opt);

% The following do not run on octave for now (because of spmup)
anatomicalQA(opt);
bidsResliceTpmToFunc(opt);
functionalQA(opt);

bidsSmoothing(FWHM, opt);

% The following crash on Travis CI
% bidsFFX('specifyAndEstimate', opt, FWHM);
% bidsFFX('contrasts', opt, FWHM);
% bidsResults(opt, FWHM);

%%
function dowload_MoAE_ds(downloadData)

  if downloadData

    % URL of the data set to download
    URL = 'http://www.fil.ion.ucl.ac.uk/spm/download/data/MoAEpilot/MoAEpilot.bids.zip';

    working_directory = fileparts(mfilename('fullpath'));

    % clean previous runs
    if exist(fullfile(working_directory, 'inputs'), 'dir')
      rmdir(fullfile(working_directory, 'inputs'), 's');
    end

    spm_mkdir(fullfile(working_directory, 'inputs'));

    %% Get data
    fprintf('%-10s:', 'Downloading dataset...');
    urlwrite(URL, 'MoAEpilot.zip');
    fprintf(1, ' Done\n\n');

    fprintf('%-10s:', 'Unzipping dataset...');
    unzip('MoAEpilot.zip');
    movefile('MoAEpilot', fullfile(working_directory, 'inputs', 'raw'));
    fprintf(1, ' Done\n\n');

  end

end
