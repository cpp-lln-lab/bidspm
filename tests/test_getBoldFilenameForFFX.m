% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function test_suite = test_getBoldFilenameForFFX %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getBoldFilenameForFFXBasic()

  subLabel = '01';
  funcFWHM = 6;
  iSes = 1;
  iRun = 1;

  opt = setOptions('vislocalizer', subLabel);

  opt = checkOptions(opt);

  [BIDS, opt] = getData(opt);

  [boldFileName, prefix] = getBoldFilenameForFFX(BIDS, opt, subLabel, funcFWHM, iSes, iRun);

  expectedFileName = fullfile(fileparts(mfilename('fullpath')), ...
                              'dummyData', 'derivatives', 'cpp_spm', 'sub-01', ...
                              'ses-01', 'func', ...
                              's6wusub-01_ses-01_task-vislocalizer_bold.nii');

  assertEqual('s6wu', prefix);
  assertEqual(expectedFileName, boldFileName);

end

function test_getBoldFilenameForFFXNativeSpace()

  subLabel = '01';
  funcFWHM = 6;
  iSes = 1;
  iRun = 1;

  opt = setOptions('vislocalizer', subLabel);
  opt.space = 'individual';

  opt = checkOptions(opt);

  [BIDS, opt] = getData(opt);

  [boldFileName, prefix] = getBoldFilenameForFFX(BIDS, opt, subLabel, funcFWHM, iSes, iRun);

  expectedFileName = fullfile(fileparts(mfilename('fullpath')), ...
                              'dummyData', 'derivatives', 'cpp_spm', 'sub-01', ...
                              'ses-01', 'func', ...
                              's6usub-01_ses-01_task-vislocalizer_bold.nii');

  assertEqual('s6u', prefix);
  assertEqual(expectedFileName, boldFileName);

end
