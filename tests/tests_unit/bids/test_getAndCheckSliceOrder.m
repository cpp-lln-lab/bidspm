% (C) Copyright 2020 CPP_SPM developers

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

  sliceOrder = getAndCheckSliceOrder(BIDS, opt, filter);

  assert(isempty(sliceOrder));

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

function test_getAndCheckSliceOrder_from_options()

  [BIDS, opt, filter] = setUp('vislocalizer');

  opt.stc.referenceSlice = 1000;
  opt.stc.sliceOrder = 0:250:2000;

  sliceOrder = getAndCheckSliceOrder(BIDS, opt, filter);

  assert(isequal(sliceOrder, opt.stc.sliceOrder));

end

function [BIDS, opt, filter] = setUp(task)

  subLabel = '^01';

  opt = setOptions(task, subLabel);

  opt.query.acq = '';

  BIDS = bids.layout(opt.dir.preproc, 'use_schema', false);

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
