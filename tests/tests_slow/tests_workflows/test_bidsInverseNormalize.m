% (C) Copyright 2022 bidspm developers

function test_suite = test_bidsInverseNormalize %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsInverseNormalize_basic()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  opt = setOptions('vismotion');

  opt.verbosity = 0;

  opt.bidsFilterFile.roi.suffix = 'probseg';
  opt.bidsFilterFile.roi.space = 'IXI549Space';
  opt.bidsFilterFile.roi.label = 'CSF';
  opt.bidsFilterFile.roi.modality = 'anat';

  matlabbatch = bidsInverseNormalize(opt);

end
