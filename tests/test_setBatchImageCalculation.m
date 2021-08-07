% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_setBatchImageCalculation %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchImageCalculationBasic()

  input = {'sub-01_ses-01_T1w.nii'};
  output = 'sub-01_ses-01_T1w_thres.nii';
  outDir = pwd;
  exp = 'i1 > 10';

  matlabbatch = {};
  matlabbatch = setBatchImageCalculation(matlabbatch, input, output, outDir, exp, 'uint8');

  expectedBatch{1}.spm.util.imcalc.input{1} = 'sub-01_ses-01_T1w.nii';
  expectedBatch{end}.spm.util.imcalc.output = 'sub-01_ses-01_T1w_thres.nii';
  expectedBatch{end}.spm.util.imcalc.outdir{1} = pwd;
  expectedBatch{end}.spm.util.imcalc.expression = 'i1 > 10';
  expectedBatch{end}.spm.util.imcalc.options.dtype = 2;

  assertEqual(matlabbatch, expectedBatch);

  assertExceptionThrown( ...
                        @()setBatchImageCalculation(matlabbatch, ...
                                                    input, ...
                                                    output, ...
                                                    outDir, ...
                                                    exp, ...
                                                    'test'), ...
                        'setBatchImageCalculation:invalidDatatype');
end
