% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_bidsSmoothing %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsSmoothing_basic()

  opt = setOptions('vislocalizer');

  opt.pipeline.type = 'preproc';

  opt.space = 'MNI';

  opt = checkOptions(opt);

  bidsSmoothing(opt);

end

function test_bidsSmoothing_fmriprep()

  opt = setOptions('fmriprep');

  opt.space = 'MNI152NLin2009cAsym';
  opt.query.space = opt.space; % for bidsCopy only
  opt.query.desc = 'preproc';

  bidsCopyInputFolder(opt, false());

  bidsSmoothing(opt);

  cleanUp(opt.dir.preproc);

end

function cleanUp(folder)

  pause(1);

  if isOctave()
    confirm_recursive_rmdir (true, 'local');
  end
  rmdir(folder, 's');

end
