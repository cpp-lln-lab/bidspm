% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_setBatchMeanAnatAndMask %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchMeanAnatAndMask_basic()

  createDummyData();

  opt = setOptions('vismotion', {'01', 'ctrl01'}, 'pipelinetype', 'stats');

  matlabbatch = {};
  matlabbatch = setBatchMeanAnatAndMask(matlabbatch, opt, pwd);

  imcalc.input{1, 1} = fullfile(opt.dir.preproc, ...
                                'sub-01', ...
                                'ses-01', ...
                                'anat', ...
                                'sub-01_ses-01_space-IXI549Space_res-hi_desc-preproc_T1w.nii');
  imcalc.input{2, 1} = fullfile(opt.dir.preproc, ...
                                'sub-ctrl01', ...
                                'ses-01', ...
                                'anat', ...
                                'sub-ctrl01_ses-01_space-IXI549Space_res-hi_desc-preproc_T1w.nii');

  imcalc.output = 'space-IXI549Space_desc-mean_T1w.nii';
  imcalc.outdir{1} = pwd;
  imcalc.expression = '(i1+i2)/2';
  imcalc.options.dtype = 16;

  expectedBatch{1}.spm.util.imcalc = imcalc;

  %
  imcalc.input{1, 1} = fullfile(opt.dir.preproc, ...
                                'sub-01', ...
                                'ses-01', ...
                                'anat', ...
                                'sub-01_ses-01_space-IXI549Space_desc-brain_mask.nii');
  imcalc.input{2, 1} = fullfile(opt.dir.preproc, ...
                                'sub-ctrl01', ...
                                'ses-01', ...
                                'anat', ...
                                'sub-ctrl01_ses-01_space-IXI549Space_desc-brain_mask.nii');

  imcalc.output = 'space-IXI549Space_desc-brain.nii';
  imcalc.outdir{1} = pwd;
  imcalc.expression = '(i1+i2)==1*2';
  imcalc.options.dtype = 16;

  expectedBatch{2}.spm.util.imcalc = imcalc;

  assertEqual(matlabbatch{1}.spm.util.imcalc.input, expectedBatch{1}.spm.util.imcalc.input);
  assertEqual(matlabbatch{1}.spm.util.imcalc.output, expectedBatch{1}.spm.util.imcalc.output);
  assertEqual(matlabbatch{2}.spm.util.imcalc.input, expectedBatch{2}.spm.util.imcalc.input);
  assertEqual(matlabbatch{2}.spm.util.imcalc.output, expectedBatch{2}.spm.util.imcalc.output);

  assertEqual(numel(matlabbatch), 7);

end
