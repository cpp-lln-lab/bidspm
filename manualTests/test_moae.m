% Script to run to check that the whole pipeline works fine
% with different options encoded in json files
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

% directory with this script becomes the current directory
WD = fullfile(fileparts(mfilename('fullpath')), '..', 'demos', 'MoAE');
cd(WD);

run ../../initCppSpm.m;

%% Set up
optionsFilesList = {'options_task-auditory.json'; ...
                    'options_task-auditory_unwarp-0.json'; ...
                    'options_task-auditory_unwarp-0_space-individual.json'; ...
                    'options_task-auditory_space-individual.json'};

if ~isGithubCi
  download_data = true;
  clean = true;
  download_moae_ds(download_data, clean);
end

for iOption = 1:size(optionsFilesList, 1)

  fprintf(1, repmat('\n', 1, 5));

  optionJsonFile = fullfile(WD, 'options', optionsFilesList{iOption});
  opt = loadAndCheckOptions(optionJsonFile);

  reportBIDS(opt);

  bidsCopyInputFolder(opt);

  bidsSpatialPrepro(opt);

  bidsSmoothing(opt);

  bidsFFX('specifyAndEstimate', opt);
  bidsFFX('contrasts', opt);
  bidsResults(opt);

  cd(WD);

  rmdir(fullfile(WD, 'outputs', 'derivatives'), 's');

end
