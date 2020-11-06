function test_suite = test_createAndReturnOnsetFile %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_createAndReturnOnsetFileBasic()

  subID = '01';
  funcFWHM = 6;
  iSes = 1;
  iRun = 1;

  opt.taskName = 'vislocalizer';
  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
  opt.subjects = {'01'};
  opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                            'dummyData', 'models', ...
                            'model-vislocalizer_smdl.json');

  opt = checkOptions(opt);

  [~, opt, BIDS] = getData(opt);

  sessions = getInfo(BIDS, subID, opt, 'sessions');
  runs = getInfo(BIDS, subID, opt, 'runs', sessions{iSes});

  tsvFile = getInfo(BIDS, subID, opt, 'filename', sessions{iSes}, runs{iRun}, 'events');

  onsetFileName = createAndReturnOnsetFile(opt, subID, tsvFile, funcFWHM);

  expectedFileName = fullfile(fileparts(mfilename('fullpath')), ...
                              'dummyData', 'derivatives', 'cpp_spm', 'sub-01', 'stats', ...
                              'ffx_task-vislocalizer', 'ffx_space-MNI_FWHM-6', ...
                              'onsets_sub-01_ses-01_task-vislocalizer_events.mat');

  assertEqual(exist(onsetFileName, 'file'), 2);
  assertEqual(exist(expectedFileName, 'file'), 2);

end
