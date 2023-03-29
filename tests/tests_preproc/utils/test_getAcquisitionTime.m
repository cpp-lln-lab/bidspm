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

function test_getAcquisitionTime_bug_967()
  % https://github.com/cpp-lln-lab/bidspm/issues/967

  repetitionTime = 2;
  sliceOrder = [0
                0.0575
                0.115
                0.1725
                0.23
                0.2875
                0.345
                0.4025
                0.46
                0.5175
                0.575
                0.6325
                0.69
                0.745
                0.8025
                0.86
                0.9175
                0.975
                1.0325
                1.09
                1.1475
                1.205
                1.2625
                1.32
                1.3775
                1.435
                1.4925
                1.55
                1.6075
                1.665
                1.7225
                1.7775
                1.835
                1.8925
                1.95];

  getAcquisitionTime(sliceOrder, repetitionTime);

end
