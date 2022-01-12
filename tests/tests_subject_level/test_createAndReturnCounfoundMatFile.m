% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_createAndReturnCounfoundMatFile %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_createAndReturnCounfoundMatFile_basic()

  [opt, tsvFile] = setUp();

  counfoundMatFile = createAndReturnCounfoundMatFile(opt, tsvFile);

  expectedFilename = fullfile(getDummyDataDir('stats'), 'sub-01', 'stats', ...
                              'task-vislocalizer_space-IXI549Space_FWHM-6', ...
                              'sub-01_ses-01_task-vislocalizer_desc-confounds_regressors.mat');

  assertEqual(exist(counfoundMatFile, 'file'), 2);
  assertEqual(exist(expectedFilename, 'file'), 2);

  expected_content = fullfile(getDummyDataDir(), 'mat_files', 'regressors.mat');

  expected_R = load(expected_content, 'R');
  actual_R = load(counfoundMatFile, 'R');
  assertEqual(actual_R, expected_R);

  expected_names = load(expected_content, 'names');
  actual_names = load(counfoundMatFile, 'names');
  assertEqual(actual_names, expected_names);

  delete(counfoundMatFile);

end

function [opt, tsvFile] = setUp()

  subLabel = '01';
  iSes = 1;
  iRun = 1;

  opt = setOptions('vislocalizer', subLabel, 'pipelineType', 'stats');

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  sessions = getInfo(BIDS, subLabel, opt, 'sessions');
  runs = getInfo(BIDS, subLabel, opt, 'runs', sessions{iSes});

  filter = struct( ...
                  'sub',  subLabel, ...
                  'task', opt.taskName, ...
                  'ses', sessions{iSes}, ...
                  'run', runs{iRun}, ...
                  'suffix', 'regressors', ...
                  'extension', '.tsv');
  tsvFile = bids.query(BIDS, 'data', filter);

end
