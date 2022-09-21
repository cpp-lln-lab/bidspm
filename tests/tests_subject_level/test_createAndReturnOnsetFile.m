function test_suite = test_createAndReturnOnsetFile %#ok<*STOUT>

  % (C) Copyright 2020 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_createAndReturnOnsetFile_basic()

  subLabel = '01';
  iSes = 1;
  iRun = 1;

  opt = setOptions('vislocalizer', subLabel, 'pipelineType', 'stats');

  BIDS = getLayout(opt);

  sessions = getInfo(BIDS, subLabel, opt, 'sessions');
  runs = getInfo(BIDS, subLabel, opt, 'runs', sessions{iSes});

  filter = struct( ...
                  'sub',  subLabel, ...
                  'task', opt.taskName, ...
                  'ses', sessions{iSes}, ...
                  'run', runs{iRun}, ...
                  'suffix', 'events', ...
                  'extension', '.tsv');
  tsvFile = bids.query(BIDS, 'data', filter);

  onsetFilename = createAndReturnOnsetFile(opt, subLabel, tsvFile);

  expectedFilename = fullfile(getDummyDataDir('stats'), 'sub-01', ...
                              'task-vislocalizer_space-IXI549Space_FWHM-6', ...
                              'sub-01_ses-01_task-vislocalizer_onsets.mat');

  assertEqual(exist(onsetFilename, 'file'), 2);
  assertEqual(exist(expectedFilename, 'file'), 2);

  expected_content = load(fullfile(getDummyDataDir(), 'mat_files', 'onsets.mat'));

  actual_content = load(onsetFilename);

  assertEqual(actual_content, expected_content);

end
