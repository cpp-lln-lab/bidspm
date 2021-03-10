% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function test_suite = test_createAndReturnOnsetFile %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_createAndReturnOnsetFileBasic()

  subLabel = '01';
  funcFWHM = 6;
  iSes = 1;
  iRun = 1;

  opt = setOptions('vislocalizer', subLabel);

  opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                            'dummyData', 'models', ...
                            'model-vislocalizer_smdl.json');

  opt = checkOptions(opt);

  [BIDS, opt] = getData(opt);

  sessions = getInfo(BIDS, subLabel, opt, 'sessions');
  runs = getInfo(BIDS, subLabel, opt, 'runs', sessions{iSes});

  tsvFile = getInfo(BIDS, subLabel, opt, 'filename', sessions{iSes}, runs{iRun}, 'events');

  onsetFileName = createAndReturnOnsetFile(opt, subLabel, tsvFile, funcFWHM);

  expectedFileName = fullfile(fileparts(mfilename('fullpath')), ...
                              'dummyData', 'derivatives', 'cpp_spm', 'sub-01', 'stats', ...
                              'ffx_task-vislocalizer', 'ffx_space-MNI_FWHM-6', ...
                              'onsets_sub-01_ses-01_task-vislocalizer_events.mat');

  assertEqual(exist(onsetFileName, 'file'), 2);
  assertEqual(exist(expectedFileName, 'file'), 2);

end
