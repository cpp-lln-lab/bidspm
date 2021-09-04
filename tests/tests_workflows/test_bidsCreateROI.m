% (C) Copyright 2021 CPP_SPM developers

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
  opt.roi.space = {'MNI', 'individual'};
  opt.dir.roi = spm_file(fullfile(opt.dir.derivatives, 'cpp_spm-roi'), 'cpath');

  opt.dryRun = false;

  cleanUp(opt.dir.roi);

  % skip test in CI
  if isOctave
    return
  end

  bidsCreateROI(opt);

  use_schema = false;
  BIDS = bids.layout(opt.dir.roi, use_schema);
  roiImages = bids.query(BIDS, 'data', 'sub', '01', 'suffix', 'mask');

  assertEqual(size(roiImages, 1), 2);

  cleanUp(opt.dir.roi);

end

function test_bidsCreateROI_wang()

  opt = setOptions('MoAE');

  opt.roi.atlas = 'wang';
  opt.roi.name = {'V1v', 'V1d'};
  opt.roi.space = {'MNI', 'individual'};
  opt.dir.roi = spm_file(fullfile(opt.dir.derivatives, 'cpp_spm-roi'), 'cpath');

  opt.dryRun = false;

  cleanUp(opt.dir.roi);

  % skip test in CI
  if isOctave
    return
  end

  bidsCreateROI(opt);

  use_schema = false;
  BIDS = bids.layout(opt.dir.roi, use_schema);
  roiImages = bids.query(BIDS, 'data', 'sub', '01', 'suffix', 'mask');

  assertEqual(size(roiImages, 1), 4);

  cleanUp(opt.dir.roi);

end

function cleanUp(folder)

  pause(.3);

  if isOctave()
    confirm_recursive_rmdir (true, 'local');
  end

  try
    rmdir(folder, 's');
  catch
  end

end
