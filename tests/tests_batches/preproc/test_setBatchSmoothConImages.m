% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_setBatchSmoothConImages %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchSmoothConImages_basic()

  createDummyData();

  opt = setOptions('vismotion', {'01', 'blind01'}, 'pipelineType', 'stats');

  matlabbatch = {};
  matlabbatch = setBatchSmoothConImages(matlabbatch, opt);

  statsFodler = fullfile(opt.dir.stats, 'sub-01', ...
                         'task-vismotion_space-IXI549Space_FWHM-6');
  expectedBatch{1}.spm.spatial.smooth.fwhm = [6 6 6];
  expectedBatch{1}.spm.spatial.smooth.prefix = 's6';
  expectedBatch{1}.spm.spatial.smooth.data = {fullfile(statsFodler, ...
                                                       'con_0001.nii'); ...
                                              fullfile(statsFodler, ...
                                                       'con_0002.nii'); ...
                                              fullfile(statsFodler, ...
                                                       'con_0003.nii'); ...
                                              fullfile(statsFodler, ...
                                                       'con_0004.nii')};
  expectedBatch{1}.spm.spatial.smooth.dtype = 0;
  expectedBatch{1}.spm.spatial.smooth.im = 0;

  statsFodler = fullfile(opt.dir.stats, 'sub-blind01', ...
                         'task-vismotion_space-IXI549Space_FWHM-6');
  expectedBatch{2}.spm.spatial.smooth.fwhm = [6 6 6];
  expectedBatch{2}.spm.spatial.smooth.prefix = 's6';
  expectedBatch{2}.spm.spatial.smooth.data = {fullfile(statsFodler, ...
                                                       'con_0001.nii'); ...
                                              fullfile(statsFodler, ...
                                                       'con_0002.nii'); ...
                                              fullfile(statsFodler, ...
                                                       'con_0003.nii'); ...
                                              fullfile(statsFodler, ...
                                                       'con_0004.nii')};
  expectedBatch{2}.spm.spatial.smooth.dtype = 0;
  expectedBatch{2}.spm.spatial.smooth.im = 0;

  assertEqual(matlabbatch{1}.spm.spatial.smooth, expectedBatch{1}.spm.spatial.smooth);
  assertEqual(matlabbatch, expectedBatch);
  assertEqual(matlabbatch, expectedBatch);

end
