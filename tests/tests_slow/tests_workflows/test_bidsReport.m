function test_suite = test_bidsReport %#ok<*STOUT>
  % (C) Copyright 2021 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsReport_smoke_test()

  markTestAs('slow');

  opt = setOptions('vismotion');

  opt.dir.output = tempName();

  bidsReport(opt);

  assertEqual(exist(fullfile(opt.dir.output, ...
                             'reports', ...
                             'sub-ctrl01', ...
                             'dataset-bidspm-raw_bids-matlab_report.md'), ...
                    'file'), ...
              2);

end

function test_bidsReport_basic()

  markTestAs('slow');

  opt = setOptions('MoAE');

  opt.dir.output = tempName();

  bidsReport(opt);

  assertEqual(exist(fullfile(opt.dir.output, ...
                             'reports', ...
                             'sub-01', ...
                             'dataset-raw_bids-matlab_report.md'), ...
                    'file'), ...
              2);

end
