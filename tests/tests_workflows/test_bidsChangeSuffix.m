function test_suite = test_bidsChangeSuffix %#ok<*STOUT>
  % (C) Copyright 2020 CPP_SPM developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsChangeSuffix_basic()

  dataset = 'ds001';

  dataDir = getBidsExample('ds001');

  dataset_dir = fullfile(dataDir, '..', '..', 'tmp', dataset);

  bids.util.mkdir(dataset_dir);
  copyfile(dataDir, dataset_dir);

  opt.dir.input = dataset_dir;
  opt.dryRun = false;
  opt.verbosity = 0;
  opt.useBidsSchema = false;

  BIDS_before = bids.layout(opt.dir.input, 'use_schema', false);

  expected = bids.query(BIDS_before, 'data', 'suffix', 'bold');
  expected_metadata = bids.query(BIDS_before, 'metadata', 'suffix', 'bold');

  %% WHEN
  bidsChangeSuffix(opt, 'vaso', 'filter', struct('suffix', 'bold'), 'force', true);

  %% THEN
  BIDS_after = bids.layout(dataset_dir, 'use_schema', false);

  % only vaso
  data = bids.query(BIDS_after, 'data', 'suffix', 'vaso');
  assertEqual(numel(data), numel(expected));

  % no bold
  data = bids.query(BIDS_after, 'data', 'suffix', 'bold');
  assertEqual(numel(data), 0);

  % same metadata
  metadata = bids.query(BIDS_before, 'metadata', 'suffix', 'vaso');
  assertEqual(metadata, expected_metadata);

  rmdir(dataset_dir, 's');

end
