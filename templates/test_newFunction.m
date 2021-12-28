function test_suite = test_newFunction %#ok<*STOUT>
  %
  % (C) Copyright 2019 CPP_SPM developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_newFunction_basic()

  % GIVEN
  subLabel = '01';
  opt = setOptions('dummy', subLabel);

  % WHEN
  foo = test_newFunction(opt);

  % THEN
  expectedContent = 'faa';
  assertEqual(foo, expectedContent);

  cleanUp();

end

function setUp()

end

function cleanUp()

end
