function test_suite = test_saveOptions %#ok<*STOUT>
  % (C) Copyright 2020 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_saveOptions_basic()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  opt = setOptions('dummy');
  opt.dir.derivatives = tempName();

  saveOptions(opt);

  expected = fullfile(opt.dir.derivatives, 'options', ['options_task-dummy_' timeStamp()  '.json']);

  assertEqual(exist(expected, 'file'), 2);

end
