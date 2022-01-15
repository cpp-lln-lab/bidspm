function test_suite = test_getROIs %#ok<*STOUT>
  %
  % (C) Copyright 2022 CPP_SPM developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_getROIs_mni()

  opt = setTestCfg();
  opt.dir.roi = getDummyDataDir('roi');
  opt.space = 'MNI';
  opt = checkOptions(opt);

  [roiList, roiFolder] = getROIs(opt);

  expectedFolder = fullfile(opt.dir.roi, 'group');
  assertEqual(roiFolder, expectedFolder);

  expectedRoiLists = {fullfile(roiFolder, 'A1_mask.nii'); ...
                      fullfile(roiFolder, 'V1_mask.nii')};
  assertEqual(roiList, expectedRoiLists);

end

function test_getROIs_mni_subselect()

  opt = setTestCfg();
  opt.dir.roi = getDummyDataDir('roi');
  opt.space = 'MNI';
  opt = checkOptions(opt);
  opt.roi.name = {'V1'};

  [roiList, roiFolder] = getROIs(opt);

  expectedFolder = fullfile(opt.dir.roi, 'group');
  assertEqual(roiFolder, expectedFolder);

  expectedRoiLists = {fullfile(roiFolder, 'V1_mask.nii')};
  assertEqual(roiList, expectedRoiLists);

end

function test_getROIs_individual()

  opt = setTestCfg();
  subLabel = '01';
  opt.dir.roi = getDummyDataDir('roi');
  opt.space = 'individual';
  opt = checkOptions(opt);

  [roiList, roiFolder] = getROIs(opt, subLabel);

  expectedFolder = fullfile(opt.dir.roi, 'sub-01', 'roi');
  assertEqual(roiFolder, expectedFolder);

  expectedRoiLists = {fullfile(roiFolder, 'sub-01_hemi-L_space-individual_label-A1_mask.nii'); ...
                      fullfile(roiFolder, 'sub-01_hemi-L_space-individual_label-V1_mask.nii'); ...
                      fullfile(roiFolder, 'sub-01_hemi-R_space-individual_label-A1_mask.nii'); ...
                      fullfile(roiFolder, 'sub-01_hemi-R_space-individual_label-V1_mask.nii')};
  assertEqual(roiList, expectedRoiLists);

end
