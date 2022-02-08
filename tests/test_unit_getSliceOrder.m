% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_unit_getSliceOrder %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getSliceOrderBasic()

  opt = setOptions('vismotion');

  [~, opt] = getData(opt);
  BIDS_sliceOrder = getSliceOrder(opt, 0);

  %% Get slice order from BIDS
  sliceOrder = repmat( ...
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

  assert(isequal(sliceOrder, BIDS_sliceOrder));

end

function test_getSliceOrderEmpty()

  opt = setOptions('vislocalizer');

  [~, opt] = getData(opt);

  BIDS_sliceOrder = getSliceOrder(opt, 0);

  assert(isempty(BIDS_sliceOrder));

end

function test_getSliceOrderFromOptions()

  opt = setOptions('vislocalizer');
  opt.stc.referenceSlice = 1000;
  opt.stc.sliceOrder = 0:250:2000;

  [~, opt] = getData(opt);
  BIDS_sliceOrder = getSliceOrder(opt, 0);
  assert(isequal(BIDS_sliceOrder, opt.stc.sliceOrder));

end
