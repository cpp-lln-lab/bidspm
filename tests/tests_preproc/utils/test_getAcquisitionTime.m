function test_suite = test_getAcquisitionTime %#ok<*STOUT>
  % (C) Copyright 2023 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getAcquisitionTime_basic()

  repetitionTime = 1.5;
  sliceOrder = repmat([0.5475, 0,    0.3825, 0.055, 0.4375, 0.11, ...
                       0.4925, 0.22, 0.6025, 0.275, 0.6575, 0.3275, ...
                       0.71,   0.165], ...
                      1, 3)';

  acquisitionTime = getAcquisitionTime(sliceOrder, repetitionTime);

  assertElementsAlmostEqual(acquisitionTime, 1.3929, 'absolute', 1e-4);

end

function test_getAcquisitionTime_error()

  repetitionTime = 1.5;
  sliceOrder = repmat([0.5475, 0,    0.3825, 0.055, 0.4375, 0.11, ...
                       0.4925, 0.22, 0.6025, 0.275, 0.6575, 0.3275, ...
                       0.71,   1.49], ...
                      1, 3)';

  assertExceptionThrown(@() getAcquisitionTime(sliceOrder, repetitionTime), ...
                        'getAcquisitionTime:sliceTimingSuperiorToAcqTime');

end
