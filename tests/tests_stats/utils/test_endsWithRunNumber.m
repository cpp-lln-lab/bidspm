function test_suite = test_endsWithRunNumber %#ok<*STOUT>
  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_endsWithRunNumber_basic()

  % no run label or session label could be inferred from bids names
  assertEqual(endsWithRunNumber('foo_1'), true);
  assertEqual(endsWithRunNumber('foo_10'), true);

  % session label but not run label could be inferred from bids names
  % the session has only one run with no run label in the file name
  assertEqual(endsWithRunNumber('foo_ses-1'), true);
  assertEqual(endsWithRunNumber('foo_ses-29'), true);

  % only run label could be inferred from bids names
  % there is only one session
  % but it is not used explicitly in the filenames
  assertEqual(endsWithRunNumber('foo_run-1'), true);
  assertEqual(endsWithRunNumber('foo_run-05'), true);

  % subject level contrast names should have nothing appended
  assertEqual(endsWithRunNumber('foo'), false);
  assertEqual(endsWithRunNumber('foo_1_'), false);
  assertEqual(endsWithRunNumber('foo_1_a'), false);
  assertEqual(endsWithRunNumber('foo_'), false);

  % there should be an underscore
  assertEqual(endsWithRunNumber('foo1'), false);

end
