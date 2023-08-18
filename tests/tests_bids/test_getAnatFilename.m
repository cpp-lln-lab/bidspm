% (C) Copyright 2020 bidspm developers

function test_suite = test_getAnatFilename %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

% TODO
% add tests to check:
%  - that the function is smart enough to find an anat even when user has not
%    specified a session

function test_getAnatFilename_return_several()

  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel, 'useRaw', true);

  opt.bidsFilterFile.t1w.suffix = '.*';
  opt.bidsFilterFile.t1w.ses = '01';

  BIDS = getLayout(opt);

  warning('OFF');
  nbImgToReturn = 3;
  anatImage = getAnatFilename(BIDS, opt, subLabel, nbImgToReturn);

  assertEqual(numel(anatImage), 3);
  warning('ON');

  if bids.internal.is_octave()
    moxunit_throw_test_skipped_exception('Octave:mixed-string-concat warning thrown');
  end

  assertWarning(@()getAnatFilename(BIDS, opt, subLabel, nbImgToReturn), ...
                'getAnatFilename:severalAnatFile');

end

function test_getAnatFilename_forced_session()

  subLabel = '01';

  opt = setOptions('rest', subLabel, 'useRaw', true);

  opt.bidsFilterFile.t1w.suffix = 'T1w';
  opt.bidsFilterFile.t1w.ses = '01';

  BIDS = getLayout(opt);

  [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel);

  expectedAnatDataDir = fullfile(getTestDataDir('raw'), 'sub-01', 'ses-01', 'anat');

  assertEqual(anatDataDir, expectedAnatDataDir);
  assertEqual(anatImage, 'sub-01_ses-01_T1w.nii');

end

function test_getAnatFilename_derivatives()

  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel);

  BIDS = getLayout(opt);

  opt.bidsFilterFile.t1w.space = opt.space;
  opt.bidsFilterFile.t1w.desc = 'biascor';

  [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel);

  expectedFilename = 'sub-01_ses-01_space-individual_desc-biascor_T1w.nii';

  expectedAnatDataDir = fullfile(getTestDataDir('preproc'), 'sub-01', 'ses-01', 'anat');

  assertEqual(anatDataDir, expectedAnatDataDir);
  assertEqual(anatImage, expectedFilename);

end

function test_getAnatFilename_basic()

  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel, 'useRaw', true);

  BIDS = getLayout(opt);

  [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel);

  assertEqual(anatImage, 'sub-01_ses-01_T1w.nii');

  expectedAnatDataDir = fullfile(getTestDataDir('raw'), 'sub-01', 'ses-01', 'anat');
  assertEqual(anatDataDir, expectedAnatDataDir);

  %%
  opt.bidsFilterFile.t1w.suffix = 'T1w';
  opt.bidsFilterFile.t1w.ses = '01';

  [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel);

  assertEqual(anatDataDir, expectedAnatDataDir);
  assertEqual(anatImage, 'sub-01_ses-01_T1w.nii');

  %% different subject
  subLabel = 'ctrl01';

  anatImage = getAnatFilename(BIDS, opt, subLabel);
  assertEqual(anatImage, 'sub-ctrl01_ses-01_T1w.nii');

end

function test_getAnatFilename_no_session()

  subLabel = '01';
  opt = setOptions('MoAE-preproc');

  BIDS = bids.layout(opt.dir.input, ...
                     'use_schema', false, ...
                     'index_dependencies', false);

  [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel);

  expectedFilename = 'sub-01_T1w.nii';
  expectedAnatDataDir = fullfile(opt.dir.preproc, 'sub-01', 'anat');

  assertEqual(anatDataDir, expectedAnatDataDir);
  assertEqual(anatImage, expectedFilename);

end

function test_getAnatFilename_error_type()

  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel);

  opt.bidsFilterFile.t1w.suffix = 'T2w';

  BIDS = getLayout(opt);

  assertExceptionThrown( ...
                        @()getAnatFilename(BIDS, opt, subLabel), ...
                        'getAnatFilename:requestedSuffixUnvailable');
end

function test_getAnatFilename_error_session()

  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel);

  opt.bidsFilterFile.t1w.ses = '001';

  BIDS = getLayout(opt);

  assertExceptionThrown(@()getAnatFilename(BIDS, opt, subLabel), ...
                        'getAnatFilename:requestedSessionUnvailable');

end
