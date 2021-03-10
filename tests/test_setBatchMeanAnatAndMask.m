% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function test_suite = test_setBatchMeanAnatAndMask %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchMeanAnatAndMaskBasic()

  funcFWHM = 6;

  opt = setOptions('vismotion');
  opt.subjects = {'01', '02'};

  opt = setDerivativesDir(opt);
  opt = checkOptions(opt);

  matlabbatch = [];
  matlabbatch = setBatchMeanAnatAndMask(matlabbatch, opt, funcFWHM, pwd);

  %
  expectedBatch{1}.spm.util.imcalc.input{1, 1} = fullfile(opt.derivativesDir, ...
                                                          'sub-01', ...
                                                          'ses-01', ...
                                                          'anat', ...
                                                          'wmsub-01_ses-01_T1w.nii');
  expectedBatch{1}.spm.util.imcalc.input{2, 1} = fullfile(opt.derivativesDir, ...
                                                          'sub-02', ...
                                                          'ses-01', ...
                                                          'anat', ...
                                                          'wmsub-02_ses-01_T1w.nii');

  expectedBatch{1}.spm.util.imcalc.output = 'meanAnat.nii';
  expectedBatch{1}.spm.util.imcalc.outdir{1} = pwd;
  expectedBatch{1}.spm.util.imcalc.expression = '(i1+i2)/2';

  %
  expectedBatch{2}.spm.util.imcalc.input{1, 1} = fullfile(opt.derivativesDir, 'sub-01', ...
                                                          'stats', ...
                                                          'ffx_task-vismotion', ...
                                                          'ffx_space-MNI_FWHM-6', 'mask.nii');
  expectedBatch{2}.spm.util.imcalc.input{2, 1} = fullfile(opt.derivativesDir, ...
                                                          'sub-02', ...
                                                          'stats', ...
                                                          'ffx_task-vismotion', ...
                                                          'ffx_space-MNI_FWHM-6', 'mask.nii');

  expectedBatch{2}.spm.util.imcalc.output = 'meanMask.nii';
  expectedBatch{2}.spm.util.imcalc.outdir{1} = pwd;
  expectedBatch{2}.spm.util.imcalc.expression = '(i1+i2)>0.75*2';

  assertEqual(matlabbatch, expectedBatch);

end
