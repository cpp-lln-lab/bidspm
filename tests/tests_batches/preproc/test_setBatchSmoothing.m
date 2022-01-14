% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_setBatchSmoothing %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchSmoothing_basic()

  FWHM = 6;
  prefix = 's6_';

  opt = setOptions('dummy');

  images = { fullfile(pwd, 'sub-01_T1w.nii') };

  matlabbatch = {};
  matlabbatch = setBatchSmoothing(matlabbatch, opt,  images, FWHM, prefix);

  expectedBatch{1}.spm.spatial.smooth.fwhm = [6 6 6];
  expectedBatch{1}.spm.spatial.smooth.prefix = 's6_';
  expectedBatch{1}.spm.spatial.smooth.data = {fullfile(pwd, 'sub-01_T1w.nii')};

  expectedBatch{1}.spm.spatial.smooth.dtype = 0;
  expectedBatch{1}.spm.spatial.smooth.im = 0;

  assertEqual(matlabbatch, expectedBatch);

end
