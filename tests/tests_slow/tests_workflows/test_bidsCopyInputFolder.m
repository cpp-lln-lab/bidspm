% (C) Copyright 2020 bidspm developers

function test_suite = test_bidsCopyInputFolder %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsCopyInputFolder_basic()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  opt = setTestCfg();
  opt.dir.raw = fullfile(getMoaeDir(), 'inputs', 'raw');
  opt.dir.derivatives = fullfile(tempName(), 'derivatives');
  opt.taskName = 'auditory';
  opt.pipeline.type = 'preproc';
  opt.verbosity = 0;

  opt = checkOptions(opt);

  output_folder = fullfile(opt.dir.derivatives, 'bidspm-preproc');

  bidsCopyInputFolder(opt, 'unzip', true);

  layoutRaw = bids.layout(opt.dir.raw);
  layoutDerivatives = bids.layout(fullfile(opt.dir.preproc), ...
                                  'use_schema', false, ...
                                  'index_dependencies', false);

  assertEqual(exist(fullfile(output_folder, 'dataset_description.json'), 'file'), ...
              2);

  assertEqual(exist(fullfile(output_folder, 'sub-01', 'func', 'sub-01_task-auditory_bold.nii'), ...
                    'file'), ...
              2);

  assertEqual(exist(fullfile(output_folder, 'sub-01', 'anat', 'sub-01_T1w.nii'), ...
                    'file'), ...
              2);

  assertEqual(numel(bids.query(layoutDerivatives, 'data', 'suffix', 'events')), 0);

end

function test_bidsCopyInputFolder_fmriprep()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  opt = setTestCfg();
  opt.taskName = {'balloonanalogrisktask'};
  opt.pipeline.type = 'preproc';
  opt.dir.raw = fullfile(getFmriprepDir(), '..', 'ds001');
  opt.dir.input = getFmriprepDir();
  opt.dir.derivatives = fullfile(tempname(), 'derivatives');
  opt.query.space = 'MNI152NLin2009cAsym';
  opt.query.desc = 'preproc';
  opt.verbosity = 0;

  opt = checkOptions(opt);

  bidsCopyInputFolder(opt, 'unzip', false);

  layoutDerivatives = bids.layout(fullfile(opt.dir.preproc), ...
                                  'use_schema', false, ...
                                  'index_dependencies', false);
  data = bids.query(layoutDerivatives, 'data', 'extension', '.nii.gz');
  assertEqual(size(data, 1), 16);

  % ensure that by default data are not overwritten
  opt.verbosity = 0;
  bidsCopyInputFolder(opt, 'unzip', false);

  % or that they are
  bidsCopyInputFolder(opt, 'unzip', false, 'force', true);

end
