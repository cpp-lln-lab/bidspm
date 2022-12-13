% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsCreateROI %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsCreateROI_neuromorphometrics()

  opt = setOptions('MoAE');

  opt.roi.atlas = 'neuromorphometrics';
  opt.roi.name = {'Amygdala'};
  opt.roi.space = {'IXI549Space', 'individual'};
  opt.dir.roi = spm_file(fullfile(opt.dir.derivatives, 'bidspm-roi'), 'cpath');

  opt.dryRun = false;

  cleanUp(opt.dir.roi);

  % skip test in CI
  if isGithubCi
    return
  end

  bidsCreateROI(opt);

  BIDS = bids.layout(opt.dir.roi, 'use_schema', false);
  roiImages = bids.query(BIDS, 'data', 'sub', '^01', 'suffix', 'mask');

  assertEqual(size(roiImages, 1), 2);

  cleanUp(opt.dir.roi);

end

function test_bidsCreateROI_wang()

  opt = setOptions('MoAE');

  opt.roi.atlas = 'wang';
  opt.roi.name = {'V1v', 'V1d'};
  opt.roi.space = {'IXI549Space', 'individual'};
  opt.dir.roi = spm_file(fullfile(opt.dir.derivatives, 'bidspm-roi'), 'cpath');

  opt.dryRun = false;

  cleanUp(opt.dir.roi);

  % skip test in CI
  if isGithubCi
    return
  end

  bidsCreateROI(opt);

  BIDS = bids.layout(opt.dir.roi, 'use_schema', false);
  roiImages = bids.query(BIDS, 'data', 'sub', '^01', 'suffix', 'mask');

  assertEqual(size(roiImages, 1), 4);

  cleanUp(opt.dir.roi);

end

function test_bidsCreateROI_CLI()

  bidspm(pwd, fullfile(pwd, 'tmp'), ...
         'action', 'create_roi', ...
         'roi_atlas', 'wang', ...
         'roi_name', {'V1v', 'V1d'}, ...
         'space', {'IXI549Space'});

  bidspm(pwd, fullfile(pwd, 'tmp'), ...
         'action', 'create_roi', ...
         'roi_atlas', 'visfatlas', ...
         'roi_name', {'OTS'}, ...
         'space', {'IXI549Space'});

  bidspm(pwd, fullfile(pwd, 'tmp'), ...
         'action', 'create_roi', ...
         'roi_atlas', 'neuromorphometrics', ...
         'roi_name', {'SCA subcallosal area'}, ...
         'space', {'IXI549Space'});

  if isGithubCi

    bidspm(pwd, fullfile(pwd, 'tmp'), ...
           'action', 'create_roi', ...
           'roi_atlas', 'neuromorphometrics', ...
           'roi_name', {'SCA subcallosal area'}, ...
           'space', {'individual'});

  end

  cleanUp(fullfile(pwd, 'tmp'));
  cleanUp(fullfile(pwd, 'options'));
  cleanUp(fullfile(pwd, 'error_logs'));

end
