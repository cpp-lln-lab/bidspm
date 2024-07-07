function test_suite = test_endsWithRunNumber %#ok<*STOUT>
  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_endsWithRunNumber_basic()

  assertEqual(endsWithRunNumber('foo_1'), true);
  assertEqual(endsWithRunNumber('foo_1_'), false);
  assertEqual(endsWithRunNumber('foo_1_a'), false);
  assertEqual(endsWithRunNumber('foo_'), false);
  assertEqual(endsWithRunNumber('foo'), false);
  assertEqual(endsWithRunNumber('foo1'), false);

end
