% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsSmoothing %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsSmoothing_basic()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  opt = setOptions('vislocalizer', '^01');

  opt.pipeline.type = 'preproc';

  opt.space = 'IXI549Space';

  opt = checkOptions(opt);

  srcMetadata = bidsSmoothing(opt);

  assertEqual(srcMetadata, struct('RepetitionTime', [1.5500 1.5500], ...
                                  'SliceTimingCorrected', [false false]));

end

function test_bidsSmoothing_fmriprep()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  opt = setOptions('fmriprep', '^10');

  opt.space = 'MNI152NLin2009cAsym';
  opt.query.space = opt.space; % for bidsCopy only
  opt.query.desc = 'preproc';
  opt.query.modality = {'func'};

  bidsCopyInputFolder(opt, 'unzip', false);

  srcMetadata = bidsSmoothing(opt);

  assertEqual(srcMetadata, struct('RepetitionTime', [2 2 2], ...
                                  'SliceTimingCorrected', [false false false]));

  cleanUp(opt.dir.preproc);

end
