function test_suite = test_setDerivativesDir %#ok<*STOUT>
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

  assertEqual(opt.derivativesDir, fullfile(pwd, '..', 'derivatives', 'cpp_spm'));

end

function test_setDerivativesDirMissing()

  opt.derivativesDir = pwd;
  opt.taskName = 'testTask';
  opt = setDerivativesDir(opt);

  assertEqual(opt.derivativesDir, fullfile(pwd, 'derivatives', 'cpp_spm'));

end

function test_setDerivativesDirPreset1()

  opt.derivativesDir = fullfile(pwd, 'derivatives');
  opt.taskName = 'testTask';
  opt = setDerivativesDir(opt);

  assertEqual(opt.derivativesDir, fullfile(pwd, 'derivatives', 'cpp_spm'));

end


function test_setDerivativesDirPreset2()

  opt.derivativesDir = fullfile(pwd, 'derivatives', 'default');
  opt.taskName = 'testTask';
  opt = setDerivativesDir(opt);

  assertEqual(opt.derivativesDir, fullfile(pwd, 'derivatives', 'default'));

end
