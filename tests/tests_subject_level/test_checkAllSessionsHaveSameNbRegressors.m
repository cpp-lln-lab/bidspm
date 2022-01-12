function test_suite = test_checkAllSessionsHaveSameNbRegressors %#ok<*STOUT>
  %
  % (C) Copyright 2022 CPP_SPM developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_checkAllSessionsHaveSameNbRegressors_basic()

  spmMatFile = fullfile(getDummyDataDir(), ...
                        'mat_files', ...
                        'SPM_with_different_nb_regressor_per_run.mat');

  % WHEN
  assertExceptionThrown(@()checkAllSessionsHaveSameNbRegressors(spmMatFile), ...
                        'checkAllSessionsHaveSameNbRegressors:differentNbRegressor');

end
