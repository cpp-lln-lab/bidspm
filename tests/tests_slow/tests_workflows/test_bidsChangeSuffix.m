function test_suite = test_bidsChangeSuffix %#ok<*STOUT>

  % (C) Copyright 2020 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsChangeSuffix_basic()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  dataset = 'ds001';

  dataDir = getBidsExample('ds001');

  tmpDir = fullfile(dataDir, '..', '..', 'tmp');

  if isdir(tmpDir)
    rmdir(tmpDir, 's');
  end

  bids.util.mkdir(tmpDir);
  copyfile(dataDir, tmpDir);

  bidsDir = tmpDir;
  if bids.internal.is_octave()
    bidsDir = fullfile(tmpDir, dataset);
  end

  opt.dir.input = bidsDir;
  opt.dryRun = false;
  opt.verbosity = 0;
  opt.useBidsSchema = false;

  BIDS_before = bids.layout(opt.dir.input, 'use_schema', opt.useBidsSchema, ...
                            'index_dependencies', false);

  expected = bids.query(BIDS_before, 'data', 'suffix', 'bold');
  expected_metadata = bids.query(BIDS_before, 'metadata', 'suffix', 'bold');

  %% WHEN
  bidsChangeSuffix(opt, 'vaso', 'filter', struct('suffix', 'bold'), 'force', true);

  %% THEN
  BIDS_after = bids.layout(bidsDir, 'use_schema', opt.useBidsSchema, ...
                           'index_dependencies', false);

  % only vaso
  data = bids.query(BIDS_after, 'data', 'suffix', 'vaso');
  assertEqual(numel(data), numel(expected));

  % no bold
  data = bids.query(BIDS_after, 'data', 'suffix', 'bold');
  assertEqual(numel(data), 0);

  % same metadata
  metadata = bids.query(BIDS_after, 'metadata', 'suffix', 'vaso');
  assertEqual(metadata, expected_metadata);

  rmdir(tmpDir, 's');

end
