% (C) Copyright 2021 bidspm developers

function test_suite = test_createGlmDirName %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_createGlmDirName_error()

  opt = setOptions('dummy');
  opt.space = {'individual', 'MNI'};

  assertExceptionThrown(@()createGlmDirName(opt), 'createGlmDirName:tooManyMRISpaces');

end

function test_createGlmDirName_basic()

  opt = setOptions('dummy');
  opt.space = 'IXI549Space';
  opt.model.bm = BidsModel('file', opt.model.file);

  glmDirName = createGlmDirName(opt);

  expectedOutput = 'task-dummy_space-IXI549Space_FWHM-6';

  assertEqual(glmDirName, expectedOutput);

end

function test_createGlmDirName_aroma()

  opt = setOptions('dummy');
  opt.query.desc = {'smoothAROMAnonaggr'};
  opt.space = 'MNI152NLin6Asym';
  opt.model.bm = BidsModel('file', opt.model.file);

  glmDirName = createGlmDirName(opt);

  expectedOutput = 'task-dummy_space-MNI152NLin6Asym_FWHM-aroma';

  assertEqual(glmDirName, expectedOutput);

end
