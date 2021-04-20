% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_bidsCopyInputFolder %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsCopyInputFolder2tasks()

  system('rm -Rf dummyData/copy');

  opt.dir.input = fullfile( ...
                           fileparts(mfilename('fullpath')), ...
                           'dummyData', 'derivatives', 'cpp_spm');

  opt.pipeline.name = 'copy';

  opt.taskName = 'vismotion';
  opt.query.modality = {'anat', 'func'};
  opt = checkOptions(opt);

  unzip = false;
  bidsCopyInputFolder(opt, unzip);

  derivatives = bids.layout(fullfile(opt.dir.preproc));

  % make sure that anat, and func are there and that the fmap dependencies were
  % grabbed
  modalities = bids.query(derivatives, 'modalities');
  assertEqual(numel(modalities), 3);

  tasks = bids.query(derivatives, 'tasks');
  assertEqual(numel(tasks), 1);

  assertEqual(exist( ...
                    fullfile(opt.dir.preproc, ...
                             'sub-01', ...
                             'ses-01', ...
                             'func', ...
                             'sub-01_ses-01_task-vismotion_run-1_bold.json'), 'file'), ...
              2);

  opt.taskName = 'vislocalizer';
  bidsCopyInputFolder(opt, unzip);

  BIDS = bids.layout(fullfile(opt.dir.preproc));

  tasks = bids.query(BIDS, 'tasks');
  assertEqual(numel(tasks), 2);

  system('rm -Rf dummyData/copy');

end
