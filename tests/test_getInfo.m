function test_suite = test_getInfo %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getInfoBasic()

  % tests for when no session or only one run
  opt = setOptions();

  %% Get sessions from BIDS
  opt.taskName = 'vismotion';
  subID = 'ctrl01';
  info = 'sessions';

  opt = checkOptions(opt);

  [~, opt, BIDS] = getData(opt);

  sessions = getInfo(BIDS, subID, opt, info);
  assert(all(strcmp(sessions, {'01' '02'})));

  %% Get runs from BIDS
  session =  '01';
  info = 'runs';

  [~, opt, BIDS] = getData(opt);

  runs = getInfo(BIDS, subID, opt, info, session);
  assert(all(strcmp(runs, {'1' '2'})));

  %% Get runs from BIDS when no run in filename
  opt.taskName = 'vislocalizer';
  subID = 'ctrl01';
  session =  '01';
  info = 'runs';

  [~, opt, BIDS] = getData(opt);

  runs = getInfo(BIDS, subID, opt, info, session);
  assert(strcmp(runs, {''}));

end

function test_getInfoQuery()

  opt = setOptions();

  %% Get filename from BIDS
  opt.taskName = 'vismotion';
  subID = 'ctrl01';
  session =  '01';
  run = '1';
  info = 'filename';

  %%
  opt = checkOptions(opt);

  [~, opt, BIDS] = getData(opt);

  filename = getInfo(BIDS, subID, opt, info, session, run, 'bold');
  assertEqual(size(filename, 1), 3);

  %%
  opt.query = struct('acq', '');

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

  %%
  opt.query = struct('acq', '1p60mm', 'dir', 'PA');

  filename = getInfo(BIDS, subID, opt, info, session, run, 'bold');
  FileName = fullfile(fileparts(mfilename('fullpath')), 'dummyData',  ...
                      'derivatives', 'cpp_spm', ...
                      ['sub-' subID], ['ses-' session], 'func', ...
                      ['sub-' subID, ...
                       '_ses-' session, ...
                       '_task-' opt.taskName, ...
                       '_acq-' '1p60mm', ...
                       '_dir-' 'PA', ...
                       '_run-' run, ...
                       '_bold.nii']);

  assert(strcmp(filename, FileName));

end

function test_getInfoQueryWithSessionRestriction()

  opt = setOptions();

  opt.taskName = 'vismotion';

  subID = 'ctrl01';

  opt = checkOptions(opt);

  [~, opt, BIDS] = getData(opt);

  opt.query = struct('ses', {{'01', '02'}});
  [~, nbSessions] = getInfo(BIDS, subID, opt, 'sessions');
  assertEqual(nbSessions, numel(opt.query.ses));

  opt.query = struct('ses', '02');
  [sessions, nbSessions] = getInfo(BIDS, subID, opt, 'sessions');
  assertEqual(nbSessions, numel(opt.query));
  assertEqual(sessions{1}, opt.query.ses);

end

function opt = setOptions()
  opt.derivativesDir = fullfile( ...
                                fileparts(mfilename('fullpath')), ...
                                'dummyData', ...
                                'derivatives', ...
                                'cpp_spm');
  opt.groups = {''};
  opt.subjects = {[], []};

end
