function test_suite = test_displayArguments %#ok<*STOUT>
  % (C) Copyright 2023 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_displayArguments_basic()

  displayArguments(1, 'a', true, false, {'a', 'b', 'c'}, struct(), pwd);
end
