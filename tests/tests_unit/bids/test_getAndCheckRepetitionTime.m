function test_suite = test_getAndCheckRepetitionTime %#ok<*STOUT>
  %
  % (C) Copyright 2019 CPP_SPM developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_getAndCheckRepetitionTime_dual_task()

  [BIDS, filter] = setUp({'vismotion', 'rest'});

  repetitionTime = getAndCheckRepetitionTime(BIDS, filter);
  assertEqual(repetitionTime, 1.5);

end

function test_getAndCheckRepetitionTime_no_repetition_time()

  % GIVEN
  [BIDS, filter] = setUp({'dummy'});

  % THEN
  assertExceptionThrown(@()getAndCheckRepetitionTime(BIDS, filter), ...
                        'getAndCheckRepetitionTime:noRepetitionTimeFound');

end

function test_getAndCheckRepetitionTime_basic()

  % GIVEN
  [BIDS, filter] = setUp({'vismotion'});

  % THEN
  repetitionTime = getAndCheckRepetitionTime(BIDS, filter);
  assertEqual(repetitionTime, 1.5);

end

function test_getAndCheckRepetitionTime_error_different_repetition_time()

  % GIVEN
  [BIDS, filter] = setUp({'vismotion', 'vislocalizer'});

  % THEN
  assertExceptionThrown( ...
                        @()getAndCheckRepetitionTime(BIDS, filter), ...
                        'getAndCheckRepetitionTime:differentRepetitionTime');

end

function [BIDS, filter] = setUp(task)

  subLabel = '^01';

  opt = setOptions(task, subLabel);

  opt.query.acq = '';

  BIDS = bids.layout(opt.dir.preproc, 'use_schema', false);

  filter = opt.query;
  filter.sub =  subLabel;
  filter.suffix = 'bold';
  filter.extension = {'.nii', '.nii.gz'};
  filter.prefix = '';
  if ~isfield(filter, 'task')
    filter.task = opt.taskName;
  end

end
