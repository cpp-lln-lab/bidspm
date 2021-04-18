% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_unit_setDerivativesDir %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setDerivativesDirBasic()

  opt.dir.raw = pwd;
  opt.taskName = 'testTask';
  opt = setDerivativesDir(opt);

  expected.raw = pwd;
  expected.derivatives = spm_file(fullfile(pwd, '..', 'derivatives', 'cpp_spm'), 'cpath');
  expected.jobs = fullfile(expected.derivatives, 'jobs', opt.taskName);
  assertEqual(opt.dir, expected);

end

function test_setDerivativesDirMissing()

  opt.dir.derivatives = pwd;
  opt.taskName = 'testTask';
  opt = setDerivativesDir(opt);

  expected.derivatives = spm_file(fullfile(pwd, 'derivatives', 'cpp_spm'), 'cpath');
  expected.jobs = fullfile(expected.derivatives, 'jobs', opt.taskName);
  assertEqual(opt.dir, expected);

end

function test_setDerivativesDirPreset1()

  opt.dir.derivatives = fullfile(pwd, 'derivatives');
  opt.taskName = 'testTask';
  opt = setDerivativesDir(opt);

  expected = spm_file(fullfile(pwd, 'derivatives', 'cpp_spm'), 'cpath');
  assertEqual(opt.dir.derivatives, expected);

end

function test_setDerivativesDirPreset2()

  opt.dir.derivatives = fullfile(pwd, 'derivatives', 'default');
  opt.taskName = 'testTask';
  opt = setDerivativesDir(opt);

  expected = spm_file(fullfile(pwd, 'derivatives', 'default'), 'cpath');
  assertEqual(opt.dir.derivatives, expected);

end
