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
  iSes = 1;
  iRun = 1;

  opt = setOptions('vislocalizer', subLabel);

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  opt.query = struct('acq', '');

  sessions = getInfo(BIDS, subLabel, opt, 'Sessions');

  runs = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

  [fileName, subFuncDataDir] = getBoldFilename( ...
                                               BIDS, ...
                                               subLabel, sessions{iSes}, runs{iRun}, opt);

  expectedFileName = 'sub-01_ses-01_task-vislocalizer_bold.nii';

  expectedSubFuncDataDir = fullfile(fileparts(mfilename('fullpath')), ...
                                    'dummyData', 'derivatives', 'cpp_spm-preproc', ...
                                    'sub-01', 'ses-01', 'func');

  assertEqual(expectedSubFuncDataDir, subFuncDataDir);
  assertEqual(expectedFileName, fileName);

end

function test_getBoldFilenameDerivatives()

  subLabel = '01';
  iSes = 1;
  iRun = 1;

  opt = setOptions('vismotion', subLabel);
  opt.useBidsSchema = false;

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  opt.query = struct('desc', 'stc');

  sessions = getInfo(BIDS, subLabel, opt, 'Sessions');

  runs = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

  [fileName, subFuncDataDir] = getBoldFilename( ...
                                               BIDS, ...
                                               subLabel, sessions{iSes}, runs{iRun}, opt);

  expectedFileName = 'sub-01_ses-01_task-vismotion_run-1_space-individual_desc-stc_bold.nii';

  expectedSubFuncDataDir = fullfile(fileparts(mfilename('fullpath')), ...
                                    'dummyData', 'derivatives', 'cpp_spm-preproc', ...
                                    'sub-01', 'ses-01', 'func');

  assertEqual(expectedSubFuncDataDir, subFuncDataDir);
  assertEqual(expectedFileName, fileName);

end
