function test_suite = test_matToTsv %#ok<*STOUT>
  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_onsetMatToTsv_basic()
  tmpDir = tempName();
  copyfile(fullfile(getTestDataDir(), 'mat_files'), tmpDir);

  onsetsMatFile = fullfile(tmpDir, 'task-olfid_onsets.mat');

  onsetsTsvFile = onsetsMatToTsv(onsetsMatFile);

  assertEqual(exist(onsetsTsvFile, 'file'), 2);
end

function test_regressorsMatToTsv_basic()
  tmpDir = tempName();
  copyfile(fullfile(getTestDataDir(), 'mat_files'), tmpDir);

  regressorsMatFile = fullfile(tmpDir, 'task-olfid_desc-confounds_regressors.mat');

  regressorsTsvFile = regressorsMatToTsv(regressorsMatFile);

  assertEqual(exist(regressorsTsvFile, 'file'), 2);
end
