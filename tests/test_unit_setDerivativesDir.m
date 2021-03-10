% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function test_suite = test_unit_setDerivativesDir %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setDerivativesDirBasic()

  opt.dataDir = pwd;
  opt.taskName = 'testTask';
  opt = setDerivativesDir(opt);

  expected = spm_file(fullfile(pwd, '..', 'derivatives', 'cpp_spm'), 'cpath');
  assertEqual(opt.derivativesDir, expected);

end

function test_setDerivativesDirMissing()

  opt.derivativesDir = pwd;
  opt.taskName = 'testTask';
  opt = setDerivativesDir(opt);

  expected = spm_file(fullfile(pwd, 'derivatives', 'cpp_spm'), 'cpath');
  assertEqual(opt.derivativesDir, expected);

end

function test_setDerivativesDirPreset1()

  opt.derivativesDir = fullfile(pwd, 'derivatives');
  opt.taskName = 'testTask';
  opt = setDerivativesDir(opt);

  expected = spm_file(fullfile(pwd, 'derivatives', 'cpp_spm'), 'cpath');
  assertEqual(opt.derivativesDir, expected);

end

function test_setDerivativesDirPreset2()

  opt.derivativesDir = fullfile(pwd, 'derivatives', 'default');
  opt.taskName = 'testTask';
  opt = setDerivativesDir(opt);

  expected = spm_file(fullfile(pwd, 'derivatives', 'default'), 'cpath');
  assertEqual(opt.derivativesDir, expected);

end
