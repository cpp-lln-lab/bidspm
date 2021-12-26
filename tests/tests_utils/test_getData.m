% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_getData %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getData_metadata()

  subLabel = '01';

  opt = setOptions('vismotion', subLabel);

  % to speed up testing we use the raw dummy data
  opt.dir.preproc = getDummyDataDir('raw');

  [~, opt] = getData(opt, opt.dir.preproc, 'T1w');

  assert(isequal(opt.metadata.RepetitionTime, 2.3));

end

function test_getData_error_no_matching_task()

  opt = setOptions('dummy');

  % to speed up testing we use the raw dummy data
  opt.dir.preproc = getDummyDataDir('raw');

  assertExceptionThrown( ...
                        @()getData(opt, opt.dir.preproc), ...
                        'getData:noMatchingTask');

end

function test_getData_get_also_raw_data_for_stats_pipeline()

  opt = setOptions('fmriprep');
  opt.pipeline.type = 'stats';

  [BIDS, opt] = getData(opt, opt.dir.input);

  assert(isfield(BIDS, 'raw'));
  assert(~isempty(bids.query(BIDS.raw, 'data', 'suffix', 'events')));

end
