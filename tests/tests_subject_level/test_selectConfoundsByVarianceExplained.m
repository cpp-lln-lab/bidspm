function test_suite = test_selectConfoundsByVarianceExplained %#ok<*STOUT>
% (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_selectConfoundsByVarianceExplained_basic()

  testDir = fullfile(getDummyDataDir(), 'tsv_files');
  
  tsvFile = fullfile(testDir, 'sub-01_task-auditory_desc-confounds_timeseries.tsv');
  jsonFile = fullfile(testDir, 'sub-01_task-auditory_desc-confounds_timeseries.json');
  
  tsvContent = bids.util.tsvread(tsvFile);
  metadata = bids.util.tsvread(jsonFile);

  newTsvContent = selectConfoundsByVarianceExplained(tsvContent, metadata);

  
end
