function test_suite = test_warnings %#ok<*STOUT>
  %

  % (C) Copyright 2022 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_noSPMmat()

  opt.verbosity = 0;
  subLabel = '01';

  % GIVEN
  spmMatFile = fullfile(getDummyDataDir(), 'mat_files', 'SPM.mat');
  % WHEN
  status = noSPMmat(opt, subLabel, spmMatFile);
  % THEN
  assertEqual(status, false);

  % GIVEN
  spmMatFile = fullfile(pwd, 'sub-01', 'stats', 'foo', 'SPM.mat');
  % WHEN
  status = noSPMmat(opt, subLabel, spmMatFile);
  % THEN
  assertEqual(status, true);

  if bids.internal.is_octave()
    return
  end
  opt.verbosity = 1;
  assertWarning(@()noSPMmat(opt, subLabel, spmMatFile), 'noSPMmat:noSpecifiedModel');

end

function test_noRoiFound()

  % GIVEN
  opt.verbosity = 0;
  roiList{1} = '';
  % WHEN
  status = noRoiFound(opt, roiList);
  % THEN
  assertEqual(status, true);

  if bids.internal.is_octave()
    return
  end
  opt.verbosity = 1;
  assertWarning(@()noRoiFound(opt, roiList), 'noRoiFound:noRoiFile');

end

function test_notImplemented()

  if bids.internal.is_octave()
    return
  end
  opt.verbosity = 1;
  assertWarning(@()notImplemented('foo', '', opt), 'foo:notImplemented');

end

function test_isTtest()

  % GIVEN
  tmp.Test = 't';
  % WHEN
  status = isTtest(tmp);
  % THEN
  assertEqual(status, true);

  % GIVEN
  tmp.Test = 'f';
  % WHEN
  status = isTtest(tmp);
  % THEN
  assertEqual(status, false);

  if bids.internal.is_octave()
    return
  end
  assertWarning(@()isTtest(tmp), 'isTtest:notImplemented');

end
