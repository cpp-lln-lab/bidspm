% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsCreateROI %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsCreateROI_neuromorphometrics()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  if bids.internal.is_github_ci()
    moxunit_throw_test_skipped_exception('skip test in CI');
  end

  opt = setOptions('MoAE');

  opt.roi.atlas = 'neuromorphometrics';
  opt.roi.name = {'Amygdala'};
  opt.roi.hemi = {'L', 'R'};
  opt.roi.space = {'IXI549Space', 'individual'};

  opt.dir.roi = fullfile(tempName(), 'bidspm-roi');

  opt.dryRun = false;

  bidsCreateROI(opt);

  BIDS = bids.layout(opt.dir.roi, ...
                     'use_schema', false, ...
                     'index_dependencies', false);
  roiImages = bids.query(BIDS, 'data', 'sub', '^01', 'suffix', 'mask');

  assertEqual(size(roiImages, 1), 2);

end

function test_bidsCreateROI_wang()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  if bids.internal.is_github_ci()
    moxunit_throw_test_skipped_exception('skip test in CI');
  end

  opt = setOptions('MoAE');

  opt.roi.atlas = 'wang';
  opt.roi.name = {'V1v', 'V1d'};
  opt.roi.hemi = {'L', 'R'};
  opt.roi.space = {'IXI549Space', 'individual'};
  opt.dir.roi = fullfile(tempName(), 'bidspm-roi');

  opt.dryRun = false;

  bidsCreateROI(opt);

  BIDS = bids.layout(opt.dir.roi, ...
                     'use_schema', false, ...
                     'index_dependencies', false);
  roiImages = bids.query(BIDS, 'data', 'sub', '^01', 'suffix', 'mask');

  assertEqual(size(roiImages, 1), 4);

end
