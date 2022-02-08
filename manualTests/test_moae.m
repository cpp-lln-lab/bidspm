% (C) Copyright 2019 Remi Gau
%
% Script to run to check that the whole pipeline works fine with different
% options encoded in json files
%
% - default options (that is realign & unwarp + space = MNI)
% - indidivual space
% - realign only
% - indidivual space + realign only
%
% Rudimentary attempt of a "system-level" "smoke-test" of the "happy path"...
%

clear;
clc;

% Smoothing to apply
FWHM = 6;

downloadData = true;

% URL of the data set to download
URL = 'http://www.fil.ion.ucl.ac.uk/spm/download/data/MoAEpilot/MoAEpilot.bids.zip';

% directory with this script becomes the current directory
WD = fullfile(fileparts(mfilename('fullpath')), '..', 'demos', 'MoAE');
cd(WD);

run ../../initCppSpm.m;

download_moae_ds(downloadData);

%% Set up
optionsFilesList = { ...
                    'options_task-auditory.json'; ...
                    'options_task-auditory_unwarp-0.json'; ...
                    'options_task-auditory_unwarp-0_space-individual.json'; ...
                    'options_task-auditory_space-individual.json'};

% run the pipeline with different options
for iOption = 1:size(optionsFilesList, 1)

  fprintf(1, repmat('\n', 1, 5));

  optionJsonFile = fullfile(WD, 'options', optionsFilesList{iOption});
  opt = loadAndCheckOptions(optionJsonFile);

  %% Run batches

  % reportBIDS(opt);

  bidsCopyRawFolder(opt, 1);

  bidsSTC(opt);

  bidsSpatialPrepro(opt);

  % Some of the following do not run on octave for now (because of spmup)
  % Crashes in CI
  %   anatomicalQA(opt);

  bidsResliceTpmToFunc(opt);

  % Crashes in CI
  %   functionalQA(opt);

  bidsSmoothing(FWHM, opt);

  bidsSegmentSkullStrip(opt);

  % The following crash on Travis CI
  %   bidsFFX('specifyAndEstimate', opt, FWHM);
  %   bidsFFX('contrasts', opt, FWHM);
  %   bidsResults(opt, FWHM);

  cd(WD);

end
