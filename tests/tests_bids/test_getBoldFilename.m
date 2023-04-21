% (C) Copyright 2020 bidspm developers

function test_suite = test_getBoldFilename %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getBoldFilename_basic()

  subLabel = '^01';

  opt = setOptions('vislocalizer', subLabel, 'useRaw', true);

  iSes = 1;
  iRun = 1;

  BIDS = getLayout(opt);

  opt.query = struct('acq', '', ... % to filter out raw data with acq entity
                     'space', '', 'desc', ''); % to filter out derivatives data

  sessions = getInfo(BIDS, subLabel, opt, 'Sessions');

  runs = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

  [fileName, subFuncDataDir] = getBoldFilename( ...
                                               BIDS, ...
                                               subLabel, sessions{iSes}, runs{iRun}, opt);

  expectedFilename = 'sub-01_ses-01_task-vislocalizer_bold.nii';
  expectedSubFuncDataDir = fullfile(getTestDataDir('raw'), 'sub-01', 'ses-01', 'func');

  assertEqual(subFuncDataDir, expectedSubFuncDataDir);
  assertEqual(fileName, expectedFilename);

end

function test_getBoldFilename_derivatives()

  subLabel = '^01';
  iSes = 1;
  iRun = 1;

  opt = setOptions('vismotion', subLabel);
  opt.useBidsSchema = false;

  BIDS = getLayout(opt);

  opt.query = struct('desc', 'stc', 'space', 'individual', 'acq', '');

  sessions = getInfo(BIDS, subLabel, opt, 'Sessions');

  runs = getInfo(BIDS, subLabel, opt, 'Runs', sessions{iSes});

  [fileName, subFuncDataDir] = getBoldFilename( ...
                                               BIDS, ...
                                               subLabel, sessions{iSes}, runs{iRun}, opt);

  expectedFilename = 'sub-01_ses-01_task-vismotion_run-1_space-individual_desc-stc_bold.nii';
  expectedSubFuncDataDir = fullfile(getTestDataDir('preproc'), 'sub-01', 'ses-01', 'func');

  assertEqual(subFuncDataDir, expectedSubFuncDataDir);
  assertEqual(fileName, expectedFilename);

end
