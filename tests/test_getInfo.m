function test_suite = test_getInfo %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getInfoBasic()
  % Small test to ensure that getSliceOrder returns what we asked for

  % write tests for when no session or only one run

  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), ...
                                'dummyData', 'derivatives', 'cpp_spm');
  opt = checkOptions(opt);

  %% Get sessions from BIDS
  opt.taskName = 'vismotion';
  subID = 'ctrl01';
  info = 'sessions';
  [BIDS, opt] = getData(opt);
  sessions = getInfo(BIDS, subID, opt, info);
  assert(all(strcmp(sessions, {'01' '02'})));

  %% Get runs from BIDS
  opt.taskName = 'vismotion';
  subID = 'ctrl01';
  info = 'runs';
  session =  '01';
  [BIDS, opt] = getData(opt);
  runs = getInfo(BIDS, subID, opt, info, session);
  assert(all(strcmp(runs, {'1' '2'})));

  %% Get runs from BIDS when no run in filename
  opt.taskName = 'vislocalizer';
  subID = 'ctrl01';
  info = 'runs';
  session =  '01';
  [BIDS, opt] = getData(opt);
  runs = getInfo(BIDS, subID, opt, info, session);
  assert(strcmp(runs, {''}));

  %% Get filename from BIDS
  opt.taskName = 'vismotion';
  subID = 'ctrl01';
  session =  '01';
  run = '1';
  info = 'filename';
  [BIDS, opt] = getData(opt);
  filename = getInfo(BIDS, subID, opt, info, session, run, 'bold');
  FileName = fullfile(fileparts(mfilename('fullpath')), 'dummyData',  ...
                      'derivatives', 'cpp_spm', ...
                      ['sub-' subID], ['ses-' session], 'func', ...
                      ['sub-' subID, ...
                       '_ses-' session, ...
                       '_task-' opt.taskName, ...
                       '_run-' run, ...
                       '_bold.nii']);

  assert(strcmp(filename, FileName));

end
