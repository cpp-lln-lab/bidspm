% (C) Copyright 2020 bidspm developers

function test_suite = test_createDataDictionary %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

% silence until functional QA has been updated to take BIDS as input

function test_createDataDictionary_basic()

  tsvContent.foo = [1 2];

  jsonContent = createDataDictionary(tsvContent);

  assertEqual(jsonContent, struct('foo', ''));

end
