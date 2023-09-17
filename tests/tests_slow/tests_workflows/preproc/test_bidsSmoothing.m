% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsSmoothing %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsSmoothing_basic()

  markTestAs('slow');

  opt = setOptions('vislocalizer', '^01');

  opt.pipeline.type = 'preproc';

  opt.space = 'IXI549Space';

  opt = checkOptions(opt);

  bidsSmoothing(opt);

end

function test_bidsSmoothing_fmriprep()

  markTestAs('slow');

  opt = setOptions('fmriprep', '^10');

  opt.space = 'MNI152NLin2009cAsym';
  opt.query.space = opt.space; % for bidsCopy only
  opt.query.desc = 'preproc';
  opt.query.modality = {'func'};

  bidsCopyInputFolder(opt, 'unzip', false);

  bidsSmoothing(opt);

  cleanUp(opt.dir.preproc);

end
