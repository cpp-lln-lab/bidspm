function test_suite = test_matToTsv %#ok<*STOUT>
  %
  % (C) Copyright 2022 CPP_SPM developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_onsetMatToTsv_basic()

  % GIVEN
  onsetsMatFile = fullfile(getDummyDataDir(), 'mat_files', 'task-olfid_onsets.mat');
  % WHEN
  onsetsTsvFile = onsetsMatToTsv(onsetsMatFile);
  % THEN
  assertEqual(exist(onsetsTsvFile, 'file'), 2);

  cleanUp(onsetsTsvFile);

end

function test_regressorsMatToTsv_basic()

  % GIVEN
  regressorsMatFile = fullfile(getDummyDataDir(), 'mat_files', ...
                               'task-olfid_desc-confounds_regressors.mat');
  % WHEN
  regressorsTsvFile = regressorsMatToTsv(regressorsMatFile);
  % THEN
  assertEqual(exist(regressorsTsvFile, 'file'), 2);

  cleanUp(regressorsTsvFile);

end

function setUp()

end

function cleanUp(file)
  delete(file);
end
