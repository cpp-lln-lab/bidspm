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
%
% (C) Copyright 2019 Remi Gau

clear;
clc;

% Smoothing to apply
FWHM = 6;

downloadData = true;

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
  bidsSegmentSkullStrip(opt);
  bidsSpatialPrepro(opt);

  anatomicalQA(opt);
  % bidsResliceTpmToFunc(opt);
  % functionalQA(opt);

  bidsSmoothing(FWHM, opt);

  % The following crash on CI
  %   bidsFFX('specifyAndEstimate', opt, FWHM);
  %   bidsFFX('contrasts', opt, FWHM);
  %   bidsResults(opt, FWHM);

  cd(WD);

end
