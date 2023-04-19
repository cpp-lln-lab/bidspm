% (C) Copyright 2020 bidspm developers

function test_suite = test_getAndCheckSliceOrder %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getAndCheckRepetitionTime_dual_task()

  [BIDS, opt, filter] = setUp({'vismotion', 'rest'});

  sliceOrder = getAndCheckSliceOrder(BIDS, opt, filter);

  expected = repmat( ...
                    [0.5475; ...
                     0; ...
                     0.3825; ...
                     0.0550; ...
                     0.4375; ...
                     0.1100; ...
                     0.4925; ...
                     0.2200; ...
                     0.6025; ...
                     0.2750; ...
                     0.6575; ...
                     0.3275; ...
                     0.7100; ...
                     0.1650], [3, 1]);

  assert(isequal(sliceOrder, expected));

end

function test_getAndCheckSliceOrder_inconsistent_slice_timing()

  [BIDS, opt, filter] = setUp({'vismotion', 'vislocalizer'});

  assertExceptionThrown(@()getAndCheckSliceOrder(BIDS, opt, filter), ...
                        'getAndCheckSliceOrder:inconsistentSliceTimingLength');

end

function test_getAndCheckSliceOrder_basic()

  [BIDS, opt, filter] = setUp('vismotion');

  sliceOrder = getAndCheckSliceOrder(BIDS, opt, filter);

  expected = repmat( ...
                    [0.5475; ...
                     0; ...
                     0.3825; ...
                     0.0550; ...
                     0.4375; ...
                     0.1100; ...
                     0.4925; ...
                     0.2200; ...
                     0.6025; ...
                     0.2750; ...
                     0.6575; ...
                     0.3275; ...
                     0.7100; ...
                     0.1650], [3, 1]);

  assert(isequal(sliceOrder, expected));

end

function test_getAndCheckSliceOrder_empty()

  [BIDS, opt, filter] = setUp('vislocalizer');

  sliceOrder = getAndCheckSliceOrder(BIDS, opt, filter);

  assert(isempty(sliceOrder));

end

function [BIDS, opt, filter] = setUp(task)

  subLabel = '^01';

  opt = setOptions(task, subLabel);

  opt.query.acq = '';

  BIDS = getLayout(opt);

  filter = opt.query;
  filter.sub =  subLabel;
  filter.modality = 'func';
  filter.suffix = 'bold';
  filter.extension = {'.nii', '.nii.gz'};
  filter.prefix = '';
  if ~isfield(filter, 'task')
    filter.task = opt.taskName;
  end

end
