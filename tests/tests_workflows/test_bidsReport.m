function test_suite = test_bidsReport %#ok<*STOUT>
  %

  % (C) Copyright 2021 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsReport_smoke_test()

  opt = setOptions('vismotion');

  bidsReport(opt);

  assertEqual(exist(fullfile(opt.dir.preproc, ...
                             'reports', ...
                             'sub-ctrl01', ...
                             'dataset-bidspm-raw_bids-matlab_report.md'), ...
                    'file'), ...
              2);

end

function test_bidsReport_basic()

  opt = setOptions('MoAE');

  bidsReport(opt);

end
