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
  imcalc.input{1, 1} = fullfile(opt.derivativesDir, ...
                                'sub-01', ...
                                'ses-01', ...
                                'anat', ...
                                'wmsub-01_ses-01_T1w.nii');
  imcalc.input{2, 1} = fullfile(opt.derivativesDir, ...
                                'sub-02', ...
                                'ses-01', ...
                                'anat', ...
                                'wmsub-02_ses-01_T1w.nii');

  imcalc.output = 'meanAnat.nii';
  imcalc.outdir{1} = pwd;
  imcalc.expression = '(i1+i2)/2';

  expectedBatch{1}.spm.util.imcalc = imcalc;

  %
  imcalc.input{1, 1} = fullfile(opt.derivativesDir, 'sub-01', ...
                                'stats', ...
                                'task-vismotion_space-MNI_FWHM-6', ...
                                'mask.nii');
  imcalc.input{2, 1} = fullfile(opt.derivativesDir, ...
                                'sub-02', ...
                                'stats', ...
                                'task-vismotion_space-MNI_FWHM-6', ...
                                'mask.nii');

  imcalc.output = 'meanMask.nii';
  imcalc.outdir{1} = pwd;
  imcalc.expression = '(i1+i2)>0.75*2';

  expectedBatch{2}.spm.util.imcalc = imcalc;

  assertEqual(matlabbatch, expectedBatch);

end
