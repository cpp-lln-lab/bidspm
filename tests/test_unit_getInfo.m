% (C) Copyright 2020 CPP_SPM developers

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

  info = 'sessions';

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  sessions = getInfo(BIDS, subLabel, opt, info);
  assert(all(strcmp(sessions, {'01' '02'})));

  %% Get runs from BIDS
  session =  '01';
  info = 'runs';

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  runs = getInfo(BIDS, subLabel, opt, info, session);
  assert(all(strcmp(runs, {'1' '2'})));

  %% Get runs from BIDS when no run in filename
  opt.taskName = 'vislocalizer';
  subLabel = 'ctrl01';
  session =  '01';
  info = 'runs';

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  runs = getInfo(BIDS, subLabel, opt, info, session);
  assert(strcmp(runs, {''}));

end

function test_getInfoQuery()

  subLabel = 'ctrl01';

  session =  '01';
  run = '1';
  info = 'filename';

  opt = setOptions('vismotion', subLabel);

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  filename = getInfo(BIDS, subLabel, opt, info, session, run, 'bold');
  assertEqual(size(filename, 1), 3);

  opt.query = struct('acq', '');

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

  %%
  opt.query = struct('acq', '1p60mm', 'dir', 'PA');

  filename = getInfo(BIDS, subLabel, opt, info, session, run, 'bold');
  FileName = fullfile(fileparts(mfilename('fullpath')), 'dummyData',  ...
                      'derivatives', 'cpp_spm', ...
                      ['sub-' subLabel], ['ses-' session], 'func', ...
                      ['sub-' subLabel, ...
                       '_ses-' session, ...
                       '_task-' opt.taskName, ...
                       '_acq-' '1p60mm', ...
                       '_dir-' 'PA', ...
                       '_run-' run, ...
                       '_bold.nii']);

  assert(strcmp(filename, FileName));

end

function test_getInfoQueryWithSessionRestriction()

  subLabel = 'ctrl01';

  opt = setOptions('vismotion', subLabel);

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  opt.query = struct('ses', {{'01', '02'}});
  [~, nbSessions] = getInfo(BIDS, subLabel, opt, 'sessions');
  assertEqual(nbSessions, numel(opt.query.ses));

  opt.query = struct('ses', '02');
  [sessions, nbSessions] = getInfo(BIDS, subLabel, opt, 'sessions');
  assertEqual(nbSessions, numel(opt.query));
  assertEqual(sessions{1}, opt.query.ses);

end
