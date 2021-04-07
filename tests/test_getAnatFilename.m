% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

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

function test_getAnatFilenameBasic()

  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel);

  [BIDS, opt] = getData(opt);

  [anatImage, anatDataDir] = getAnatFilename(BIDS, subLabel, opt);

  expectedFileName = 'sub-01_ses-01_T1w.nii';

  expectedAnatDataDir = fullfile(fileparts(mfilename('fullpath')), ...
                                 'dummyData', 'derivatives', 'cpp_spm', ...
                                 'sub-01', 'ses-01', 'anat');

  assertEqual(anatDataDir, expectedAnatDataDir);
  assertEqual(anatImage, expectedFileName);

  %%
  opt.anatReference.session = '01';
  opt.anatReference.type = 'T1w';

  [anatImage, anatDataDir] = getAnatFilename(BIDS, subLabel, opt);

  assertEqual(anatDataDir, expectedAnatDataDir);
  assertEqual(anatImage, expectedFileName);

end

function test_getAnatFilenameTypeError()

  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel);

  opt.anatReference.type = 'T2w';

  opt = checkOptions(opt);

  [BIDS, opt] = getData(opt);

  assertExceptionThrown( ...
                        @()getAnatFilename(BIDS, subLabel, opt), ...
                        'getAnatFilename:requestedSuffixUnvailable');

end

function test_getAnatFilenameSEssionError()

  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel);

  opt.anatReference.session = '001';

  opt = checkOptions(opt);

  [BIDS, opt] = getData(opt);

  assertExceptionThrown( ...
                        @()getAnatFilename(BIDS, subLabel, opt), ...
                        'getAnatFilename:requestedSessionUnvailable');

end
