function test_suite = test_checkOptionsSource %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_checkOptionsSourceBasic()

  optSource.nbDummies = 0;
  optSource = checkOptionsSource(optSource);

  expectedOptionsSource = defaultOptionsSource();
  expectedOptionsSource.nbDummies = 0;

  assertEqual(optSource, expectedOptionsSource);

end

function test_checkOptionsSourceDoNotOverwrite()

  optSource.dataType = 666;
  optSource.someExtraField = 'test';
  optSource.nbDummies = 42;

  optSource = checkOptionsSource(optSource);

  assertEqual(optSource.dataType, 666);
  assertEqual(optSource.someExtraField, 'test');
  assertEqual(optSource.nbDummies, 42);

end

function expectedOptionsSource = defaultOptionsSource()

  expectedOptionsSource.sourceDir = '';

  expectedOptionsSource.dataDir = '';

  expectedOptionsSource.sequenceToIgnore = {};

  expectedOptionsSource.dataType = 0;

  expectedOptionsSource.zip = 0;

  expectedOptionsSource.nbDummies = 0;

  expectedOptionsSource.sequenceRmDummies = {};

end
