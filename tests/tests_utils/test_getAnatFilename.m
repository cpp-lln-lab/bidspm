% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_getAnatFilename %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

% TODO
% add tests to check:
%  - errors when the requested file is not in the correct session
%  - that the function is smart enough to find an anat even when user has not
%    specified a session

function test_getAnatFilename_derivatives()

  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel);

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  opt.query.desc = 'biascor';

  [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel);

  expectedFilename = 'sub-01_ses-01_space-individual_desc-biascor_T1w.nii';

  expectedAnatDataDir = fullfile(getDummyDataDir('preproc'), 'sub-01', 'ses-01', 'anat');

  assertEqual(anatDataDir, expectedAnatDataDir);
  assertEqual(anatImage, expectedFilename);

end

function test_getAnatFilename_basic()

  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel, 'useRaw', true);

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel);

  expectedFilename = 'sub-01_ses-01_T1w.nii';

  expectedAnatDataDir = fullfile(getDummyDataDir('raw'), 'sub-01', 'ses-01', 'anat');

  assertEqual(anatDataDir, expectedAnatDataDir);
  assertEqual(anatImage, expectedFilename);

  %%
  opt.anatReference.session = '01';
  opt.anatReference.type = 'T1w';

  [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel);

  assertEqual(anatDataDir, expectedAnatDataDir);
  assertEqual(anatImage, expectedFilename);

end

function test_getAnatFilename_no_session()

  subLabel = '01';
  opt = setOptions('MoAE-preproc');

  [BIDS, opt] = getData(opt, opt.dir.preproc);
  [anatImage, anatDataDir] = getAnatFilename(BIDS, opt, subLabel);

  expectedFilename = 'sub-01_T1w.nii';
  expectedAnatDataDir = fullfile(opt.dir.preproc, 'sub-01', 'anat');

  assertEqual(anatDataDir, expectedAnatDataDir);
  assertEqual(anatImage, expectedFilename);

end

function test_getAnatFilename_error_type()

  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel, 'useRaw', true);

  opt.anatReference.type = 'T2w';

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  assertExceptionThrown( ...
                        @()getAnatFilename(BIDS, opt, subLabel), ...
                        'getAnatFilename:requestedSuffixUnvailable');
end

function test_getAnatFilename_error_session()

  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel, 'useRaw', true);

  opt.anatReference.session = '001';

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  assertExceptionThrown( ...
                        @()getAnatFilename(BIDS, opt, subLabel), ...
                        'getAnatFilename:requestedSessionUnvailable');

end
