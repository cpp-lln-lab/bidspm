function test_suite = test_getROIs %#ok<*STOUT>
  %
  % (C) Copyright 2022 CPP_SPM developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_getROIs_individual_space_no_subject()

  opt = setTestCfg();
  opt.dir.roi = getDummyDataDir('roi');
  opt.bidsFilterFile.roi.space = 'individual';
  opt = checkOptions(opt);

  assertExceptionThrown(@()getROIs(opt), 'getROIs:noSubject');

end

function test_getROIs_no_roi()

  opt = setTestCfg();
  opt.dir.roi = getDummyDataDir('roi');
  opt = checkOptions(opt);

  opt.roi.name = {''};

  opt.bidsFilterFile.roi.space = 'IXI549Space';
  [roiList, roiFolder] = getROIs(opt);

  assertEqual(roiFolder, '');
  assertEqual(roiList, {});

  opt.bidsFilterFile.roi.space = 'individual';
  [roiList, roiFolder] = getROIs(opt);

  assertEqual(roiFolder, '');
  assertEqual(roiList, {});

end

function test_getROIs_mni()

  opt = setTestCfg();
  opt.dir.roi = getDummyDataDir('roi');
  opt.bidsFilterFile.roi.space = 'IXI549Space';
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
  opt.bidsFilterFile.roi.space = 'IXI549Space';
  opt = checkOptions(opt);

  opt.roi.name = {'V1'};

  [roiList, roiFolder] = getROIs(opt);

  expectedRoiLists = {fullfile(roiFolder, 'V1_mask.nii')};
  assertEqual(roiList, expectedRoiLists);

  % test regex
  opt.roi.name = {'A|V'};
  roiList = getROIs(opt);
  expectedRoiLists = {fullfile(roiFolder, 'A1_mask.nii'); ...
                      fullfile(roiFolder, 'V1_mask.nii')};
  assertEqual(roiList, expectedRoiLists);

  opt.roi.name = {'.*1'};
  roiList = getROIs(opt);
  assertEqual(roiList, expectedRoiLists);

  opt.roi.name = {'A1', 'V1'};
  roiList = getROIs(opt);
  assertEqual(roiList, expectedRoiLists);

  opt.roi.name = {'foo'};
  roiList = getROIs(opt);
  assertEqual(roiList, {''});

end

function test_getROIs_individual()

  opt = setTestCfg();
  subLabel = '01';
  opt.dir.roi = getDummyDataDir('roi');
  opt.bidsFilterFile.roi.space = 'individual';
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

function test_getROIs_individual_subselect()

  opt = setTestCfg();
  subLabel = '01';
  opt.dir.roi = getDummyDataDir('roi');
  opt.bidsFilterFile.roi.space = 'individual';
  opt = checkOptions(opt);

  opt.roi.name = {'V1'};

  [roiList, roiFolder] = getROIs(opt, subLabel);

  expectedRoiLists = {fullfile(roiFolder, 'sub-01_hemi-L_space-individual_label-V1_mask.nii'); ...
                      fullfile(roiFolder, 'sub-01_hemi-R_space-individual_label-V1_mask.nii')};
  assertEqual(roiList, expectedRoiLists);

  % test regex

  opt.roi.name = {'.*1'};
  roiList = getROIs(opt, subLabel);
  expectedRoiLists = {fullfile(roiFolder, 'sub-01_hemi-L_space-individual_label-A1_mask.nii'); ...
                      fullfile(roiFolder, 'sub-01_hemi-L_space-individual_label-V1_mask.nii'); ...
                      fullfile(roiFolder, 'sub-01_hemi-R_space-individual_label-A1_mask.nii'); ...
                      fullfile(roiFolder, 'sub-01_hemi-R_space-individual_label-V1_mask.nii')};
  assertEqual(roiList, expectedRoiLists);

  opt.roi.name = {'A1', 'V1'};
  roiList = getROIs(opt, subLabel);
  assertEqual(roiList, expectedRoiLists);

  opt.roi.name = {'foo'};
  roiList = getROIs(opt, subLabel);
  assertEqual(roiList, {});

  % TODO: check why this regex fails in bids matlab
  %   opt.roi.name = {'A|V'};

  opt.roi.name = {'A', 'V'};
  roiList = getROIs(opt, subLabel);
  assertEqual(roiList, expectedRoiLists);

end

function test_getROIs_individual_subselect_filter()

  opt = setTestCfg();
  subLabel = '01';
  opt.dir.roi = getDummyDataDir('roi');
  opt.bidsFilterFile.roi.space = 'individual';
  opt = checkOptions(opt);

  opt.roi.name = struct('label', 'V1', 'hemi', 'L');

  [roiList, roiFolder] = getROIs(opt, subLabel);

  expectedRoiLists = {fullfile(roiFolder, 'sub-01_hemi-L_space-individual_label-V1_mask.nii')};
  assertEqual(roiList, expectedRoiLists);

  opt.roi.name = struct('hemi', 'L');
  roiList = getROIs(opt, subLabel);
  expectedRoiLists = {fullfile(roiFolder, 'sub-01_hemi-L_space-individual_label-A1_mask.nii'); ...
                      fullfile(roiFolder, 'sub-01_hemi-L_space-individual_label-V1_mask.nii')};
  assertEqual(roiList, expectedRoiLists);

  opt.roi.name = struct('hemi', '');
  roiList = getROIs(opt, subLabel);
  assertEqual(roiList, {});

end
