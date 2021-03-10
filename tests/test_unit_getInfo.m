% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function test_suite = test_unit_getInfo %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getInfoBasic()

  subLabel = 'ctrl01';
  opt = setOptions('vismotion', subLabel);
  opt = setDerivativesDir(opt);
  opt = checkOptions(opt);

  %% Get sessions from BIDS
  info = 'sessions';

  [BIDS, opt] = getData(opt);
  sessions = getInfo(BIDS, subLabel, opt, info);
  assert(all(strcmp(sessions, {'01' '02'})));

  %% Get runs from BIDS
  info = 'runs';

  session =  '01';

  [BIDS, opt] = getData(opt);
  runs = getInfo(BIDS, subLabel, opt, info, session);
  assert(all(strcmp(runs, {'1' '2'})));

  %% Get filename from BIDS
  info = 'filename';

  session =  '01';
  run = '1';

  [BIDS, opt] = getData(opt);
  filename = getInfo(BIDS, subLabel, opt, info, session, run, 'bold');
  FileName = fullfile(fileparts(mfilename('fullpath')), 'dummyData',  ...
                      'derivatives', 'cpp_spm', ...
                      ['sub-' subLabel], ['ses-' session], 'func', ...
                      ['sub-' subLabel, ...
                       '_ses-' session, ...
                       '_task-' opt.taskName, ...
                       '_run-' run, ...
                       '_bold.nii']);

  assert(strcmp(filename, FileName));

  %% Get runs from BIDS when no run in filename
  subLabel = 'ctrl01';
  opt = setOptions('vislocalizer', subLabel);
  opt = checkOptions(opt);

  info = 'runs';

  session =  '01';

  [BIDS, opt] = getData(opt);
  runs = getInfo(BIDS, subLabel, opt, info, session);
  assert(strcmp(runs, {''}));

end
