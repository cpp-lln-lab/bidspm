function test_suite = test_orderAndPadCounfoundMatFile %#ok<*STOUT>
  %

  % (C) Copyright 2022 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_orderAndPadCounfoundMatFile_different_nb_confounds()

  % GIVEN
  spmSess(1).counfoundMatFile = fullfile(getDummyDataDir, ...
                                         'mat_files', ...
                                         'task-olfid_desc-confounds_regressors.mat');
  spmSess(2).counfoundMatFile = fullfile(getDummyDataDir, ...
                                         'mat_files', ...
                                         'task-olfid_motion.mat');
  opt.glm.useDummyRegressor = true;

  % WHEN
  spmSessOut = orderAndPadCounfoundMatFile(spmSess, opt);

  % THEN
  assert(~strcmp(spmSessOut(2).counfoundMatFile, spmSess(2).counfoundMatFile));
  in = load(spmSess(2).counfoundMatFile);
  out = load(spmSessOut(2).counfoundMatFile);
  assertLessThan(numel(in.names), numel(out.names));
  assertEqual(numel(out.names), size(out.R, 2));

  delete(spmSessOut(2).counfoundMatFile);

end

function test_orderAndPadCounfoundMatFile_one_session()

  % GIVEN
  spmSess(1).counfoundMatFile = fullfile(getDummyDataDir, ...
                                         'mat_files', ...
                                         'task-olfid_desc-confounds_regressors.mat');
  opt.glm.useDummyRegressor = true;

  % WHEN
  spmSessOut = orderAndPadCounfoundMatFile(spmSess, opt);

  % THEN
  assertEqual(spmSessOut, spmSess);

end

function test_orderAndPadCounfoundMatFile_no_dummy_required()

  % GIVEN
  spmSess.counfoundMatFile = '';
  opt.glm.useDummyRegressor = false;

  % WHEN
  spmSessOut = orderAndPadCounfoundMatFile(spmSess, opt);

  % THEN
  assertEqual(spmSessOut, spmSess);

end

function setUp()

end

function cleanUp()

end
