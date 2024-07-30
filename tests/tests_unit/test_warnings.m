function test_suite = test_warnings %#ok<*STOUT>
  %

  % (C) Copyright 2022 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_noRoiFound()

  % GIVEN
  opt.verbosity = 0;
  roiList{1} = '';
  % WHEN
  status = noRoiFound(opt, roiList);
  % THEN
  assertEqual(status, true);

  skipIfOctave('mixed-string-concat warning thrown');
  opt.verbosity = 1;
  assertWarning(@()noRoiFound(opt, roiList), 'noRoiFound:noRoiFile');

end

function test_notImplemented()

  skipIfOctave('mixed-string-concat warning thrown');
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

  skipIfOctave('mixed-string-concat warning thrown');
  assertWarning(@()isTtest(tmp), 'isTtest:notImplemented');

end
