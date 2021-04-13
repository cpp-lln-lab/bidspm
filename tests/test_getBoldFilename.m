% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_getBoldFilename %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getBoldFilenameBasic()

  subLabel = '01';
  funcFWHM = 6;
  iSes = 1;
  iRun = 1;

  opt = setOptions('vislocalizer', subLabel);

  [BIDS, opt] = getData(opt);

  opt.query = struct('acq', '');

  sessions = getInfo(BIDS, subLabel, opt, 'Sessions');

  runs = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

  [fileName, subFuncDataDir] = getBoldFilename( ...
                                               BIDS, ...
                                               subLabel, sessions{iSes}, runs{iRun}, opt);

  expectedFileName = 'sub-01_ses-01_task-vislocalizer_bold.nii';

  expectedSubFuncDataDir = fullfile(fileparts(mfilename('fullpath')), ...
                                    'dummyData', 'derivatives', 'cpp_spm', ...
                                    'sub-01', 'ses-01', 'func');

  assertEqual(expectedSubFuncDataDir, subFuncDataDir);
  assertEqual(expectedFileName, fileName);

end
