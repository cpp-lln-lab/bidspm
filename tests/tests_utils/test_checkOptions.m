% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_checkOptions %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_checkOptions_basic()

  opt.taskName = 'testTask';
  opt = checkOptions(opt);

  expectedOptions = defaultOptions('testTask');

  assertEqual(opt, expectedOptions);

end

function test_checkOptions_do_not_overwrite()

  opt.funcVoxelDims = [1 1 1];
  opt.someExtraField = 'test';
  opt.taskName = 'testTask';

  opt = checkOptions(opt);

  assertEqual(opt.funcVoxelDims, [1 1 1]);
  assertEqual(opt.someExtraField, 'test');

end

function test_checkOptions_error_task()

  opt.taskName = [];
  opt.verbosity = 1;

  % skip in CI
  isGithubCi()
  if isGithubCi()
    return
  end

  assertWarning( ...
                @()checkOptions(opt), ...
                'checkOptions:noTask');

end

function test_checkOptions_error_group()

  opt.groups = {1};

  assertExceptionThrown( ...
                        @()checkOptions(opt), ...
                        'checkOptions:groupNotString');

end

function test_checkOptions_error_ref_slice()

  opt.stc.referenceSlice = [1:10];
  opt.taskName = 'testTask';

  assertExceptionThrown( ...
                        @()checkOptions(opt), ...
                        'checkOptions:refSliceNotScalar');

end

function test_checkOptions_error_vox_dim()

  opt.funcVoxelDims = [1:10];

  assertExceptionThrown( ...
                        @()checkOptions(opt), ...
                        'checkOptions:voxDim');

end

function test_checkOptions_session_string()

  opt.anatReference.session = 1;

  assertExceptionThrown( ...
                        @()checkOptions(opt), ...
                        'checkOptions:sessionNotString');

end
