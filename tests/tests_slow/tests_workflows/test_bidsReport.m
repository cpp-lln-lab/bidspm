function test_suite = test_bidsReport %#ok<*STOUT>
  % (C) Copyright 2021 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsReport_smoke_test()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

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

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

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
