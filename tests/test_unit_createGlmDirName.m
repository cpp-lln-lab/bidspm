% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

function test_suite = test_unit_createGlmDirName %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_createGlmDirName()

  FWHM = 6;
  opt.taskName = 'funcLocalizer';
  opt.space = 'MNI';

  glmDirName = createGlmDirName(opt, FWHM);

  expectedOutput = 'task-funcLocalizer_space-MNI_FWHM-6';

  assertEqual(glmDirName, expectedOutput);

end
