function test_suite = test_getAnatFilename %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getAnatFilenameBasic()

  subID = '01';

  opt.taskName = 'vislocalizer';
  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
  opt.groups = {''};
  opt.subjects = {subID};

  opt = checkOptions(opt);

  [~, opt, BIDS] = getData(opt);

  [anatImage, anatDataDir] = getAnatFilename(BIDS, subID, opt);

  expectedFileName = 'sub-01_ses-01_T1w.nii';

  expectedAnatDataDir = fullfile(fileparts(mfilename('fullpath')), ...
                                 'dummyData', 'derivatives', 'SPM12_CPPL', ...
                                 'sub-01', 'ses-01', 'anat');

  assertEqual(anatDataDir, expectedAnatDataDir);
  assertEqual(anatImage, expectedFileName);

end
