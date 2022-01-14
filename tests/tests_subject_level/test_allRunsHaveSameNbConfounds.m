function test_suite = test_allRunsHaveSameNbConfounds %#ok<*STOUT>
  %
  % (C) Copyright 2022 CPP_SPM developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_allRunsHaveSameNbConfounds_basic()

  % GIVEN
  spmSess(1).counfoundMatFile = fullfile(getDummyDataDir, ...
                                         'mat_files', ...
                                         'task-olfid_desc-confounds_regressors.mat');
  spmSess(2).counfoundMatFile = spmSess(1).counfoundMatFile;
  opt.glm.useDummyRegressor = true;

  % WHEN
  status = allRunsHaveSameNbConfounds(spmSess, opt);

  % THEN
  assertEqual(status, true);

end

function test_allRunsHaveSameNbConfounds_different_nb_confounds()

  % GIVEN
  spmSess(1).counfoundMatFile = fullfile(getDummyDataDir, ...
                                         'mat_files', ...
                                         'task-olfid_desc-confounds_regressors.mat');
  spmSess(2).counfoundMatFile = fullfile(getDummyDataDir, ...
                                         'mat_files', ...
                                         'task-olfid_motion.mat');
  opt.glm.useDummyRegressor = true;

  % WHEN
  status = allRunsHaveSameNbConfounds(spmSess, opt);

  % THEN
  assertEqual(status, false);

end

function test_allRunsHaveSameNbConfounds_one_session()

  % GIVEN
  spmSess(1).counfoundMatFile = fullfile(getDummyDataDir, ...
                                         'mat_files', ...
                                         'task-olfid_desc-confounds_regressors.mat');
  opt.glm.useDummyRegressor = true;

  % WHEN
  status = allRunsHaveSameNbConfounds(spmSess, opt);

  % THEN
  assertEqual(status, true);

end

function test_allRunsHaveSameNbConfounds_no_dummy_required()

  % GIVEN
  spmSess.counfoundMatFile = '';
  opt.glm.useDummyRegressor = false;

  % WHEN
  status = allRunsHaveSameNbConfounds(spmSess, opt);

  % THEN
  assertEqual(status, true);

end

function setUp()

end

function cleanUp()

end
