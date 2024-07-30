function test_suite = test_getInclusiveMask %#ok<*STOUT>

  % (C) Copyright 2020 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getInclusiveMask_too_many()

  subLabel = '01';
  nodeName = 'run_level';

  opt = setOptions('vismotion', '01', 'useTempDir', true);

  opt.verbosity = 1;

  opt.model.bm = BidsModel('file', opt.model.file);

  % dummy spec to return several images
  opt.model.bm.Nodes{1}.Model.Options.Mask.suffix{1} = 'bold';
  opt.model.bm.Nodes{1}.Model.Options.Mask.desc{1} = 'preproc';

  opt.space = opt.model.bm.Input.space;

  BIDS = getLayout(opt);

  skipIfOctave('mixed-string-concat warning thrown');

  assertWarning(@()getInclusiveMask(opt, nodeName, BIDS, subLabel), ...
                'getInclusiveMask:tooManyMasks');

end

function test_getInclusiveMask_basic()

  subLabel = '01';
  nodeName = 'run_level';

  opt = setOptions('vismotion', '01');

  opt.model.bm = BidsModel('file', opt.model.file);

  opt.space = opt.model.bm.Input.space;

  BIDS = getLayout(opt);

  mask = getInclusiveMask(opt, nodeName, BIDS, subLabel);

  assertEqual(size(mask, 1), 1);
  assertEqual(spm_file(mask, 'filename'), 'sub-01_ses-01_space-IXI549Space_desc-brain_mask.nii');

end

function test_getInclusiveMask_no_image()

  skipIfOctave('mixed-string-concat warning thrown');

  subLabel = '01';
  nodeName = 'run_level';

  opt = setOptions('vismotion', '01');

  opt.verbosity = 1;

  opt.model.bm = BidsModel('file', opt.model.file);

  opt.model.bm.Nodes{1}.Model.Options.Mask.desc{1} = 'foo';

  opt.space = opt.model.bm.Input.space;

  BIDS = getLayout(opt);

  assertWarning(@()getInclusiveMask(opt, nodeName, BIDS, subLabel), ...
                'checkMaskOrUnderlay:missingMaskOrUnderlay');

end
