% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_createGlmDirName %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_createGlmDirName_error()

  opt = setOptions('dummy');

  assertExceptionThrown(@()createGlmDirName(opt), 'createGlmDirName:tooManyMRISpaces');

end

function test_createGlmDirName_basic()

  opt = setOptions('dummy');
  opt.space = 'IXI549Space';

  glmDirName = createGlmDirName(opt);

  expectedOutput = 'task-dummy_space-IXI549Space_FWHM-6';

  assertEqual(glmDirName, expectedOutput);

end
