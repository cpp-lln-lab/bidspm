function test_suite = test_returnNumberScrubbedTimePoints %#ok<*STOUT>
  % (C) Copyright 2023 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_returnNumberScrubbedTimePoints_basic()

  assertEqual(returnNumberScrubbedTimePoints(zeros(4)), 0);
  assertEqual(returnNumberScrubbedTimePoints(ones(4)), 0);
  assertEqual(returnNumberScrubbedTimePoints(rand(4)), 0);
  assertEqual(returnNumberScrubbedTimePoints(nan(4)), 0);

  confounds = zeros(4);
  confounds(1) = 1;
  assertEqual(returnNumberScrubbedTimePoints(confounds), 1);

  confounds = nan(4);
  confounds(1) = 1;
  assertEqual(returnNumberScrubbedTimePoints(confounds), 1);

  confounds = zeros(4);
  confounds(1) = 1;
  confounds(2, 2) = 1;
  assertEqual(returnNumberScrubbedTimePoints(confounds), 2);

  % more than one 1 in one column
  confounds = zeros(4);
  confounds(1) = 1;
  confounds(2, 1) = 1;
  confounds(2, 2) = 1;
  assertEqual(returnNumberScrubbedTimePoints(confounds), 1);

end
