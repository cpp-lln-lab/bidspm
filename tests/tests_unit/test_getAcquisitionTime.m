function test_suite = test_getAcquisitionTime %#ok<*STOUT>
  %

  % (C) Copyright 2022 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

% add test for multi echo

function test_getAcquisitionTime_basic()

  sliceOrder = [1.5080
                0
                1.5500
                0.0430
                1.5920
                0.0870
                1.6350
                0.1300
                1.6770
                0.1730
                1.7220
                0.2150
                1.7650
                0.2600
                1.8080
                0.3020
                1.8500
                0.3450
                1.8930
                0.3880
                1.9380
                0.4300
                1.9800
                0.4750
                2.0220
                0.5180
                2.0650
                0.5600
                2.1100
                0.6030
                2.1520
                0.6450
                2.1950
                0.6900
                2.2380
                0.7330
                2.2800
                0.7750
                2.3250
                0.8180
                2.3670
                0.8600
                2.4100
                0.9050
                2.4530
                0.9480
                2.4950
                0.9900
                2.5400
                1.0320
                2.5830
                1.0750
                2.6250
                1.1200
                2.6680
                1.1630
                2.7100
                1.2050
                2.7550
                1.2480
                2.7980
                1.2930
                2.8400
                1.3350
                2.8830
                1.3780
                2.9250
                1.4200
                2.9500
                1.4620];

  acquisitionTime = getAcquisitionTime(sliceOrder, 3);

  assertElementsAlmostEqual(acquisitionTime, 2.9571,  'absolute', 1e-4);

end
