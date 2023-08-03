function test_suite = test_labelActivations %#ok<*STOUT>

  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_labelActivations_basic()

  csvFile = fullfile(getTestDataDir(), 'tsv_files', 'moae_results_table.csv');

  tsvFile = labelActivations(csvFile);

  assertEqual(exist(tsvFile, 'file'), 2);

  expectedFile = fullfile(getTestDataDir(), 'tsv_files', 'moae_results_table_neuromorpho.tsv');
  expectedContent = bids.util.tsvread(expectedFile);

  content = bids.util.tsvread(tsvFile);

  assertEqual(content, expectedContent);

  delete(tsvFile);

end

function test_labelActivations_all_atlases()

  atlases = {'visfatlas', ...
             'hcpex', ...
             'glasser', ...
             'wang'};

  csvFile = fullfile(getTestDataDir(), 'tsv_files', 'moae_results_table.csv');

  for i = 1:numel(atlases)
    if bids.internal.is_github_ci() && strcmp(atlases{i}, 'visfatlas')
      continue
    end
    tsvFile = labelActivations(csvFile, 'atlas', atlases{i});

    assertEqual(exist(tsvFile, 'file'), 2);

    expectedContent = bids.util.tsvread(tsvFile);
    expectedContent.([atlases{i} '_label']);

    delete(tsvFile);

  end
end

function test_labelActivations_aal()

  if bids.internal.is_github_ci()
    moxunit_throw_test_skipped_exception('no AAL in ci');
  end

  csvFile = fullfile(getTestDataDir(), 'tsv_files', 'moae_results_table.csv');

  tsvFile = labelActivations(csvFile, 'atlas', 'AAL');

  assertEqual(exist(tsvFile, 'file'), 2);

  expectedFile = fullfile(getTestDataDir(), 'tsv_files', 'moae_results_table_aal.tsv');
  expectedContent = bids.util.tsvread(expectedFile);

  content = bids.util.tsvread(tsvFile);

  assertEqual(content, expectedContent);

  delete(tsvFile);

end

function test_labelActivations_bug_662()

  if bids.internal.is_octave()
    moxunit_throw_test_skipped_exception('Octave:mixed-string-concat warning thrown');
  end

  csvFile = fullfile(getTestDataDir(), 'tsv_files', 'bug662_results_table.csv');

  assertWarning(@() labelActivations(csvFile), 'labelActivations:noSignificantVoxel');

end
