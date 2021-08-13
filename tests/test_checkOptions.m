% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_checkOptions %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_checkOptionsBasic()

  opt.taskName = 'testTask';
  opt = checkOptions(opt);

  expectedOptions = defaultOptions('testTask');

  assertEqual(opt, expectedOptions);

end

function test_checkOptionsDoNotOverwrite()

  opt.funcVoxelDims = [1 1 1];
  opt.someExtraField = 'test';
  opt.taskName = 'testTask';

  opt = checkOptions(opt);

  assertEqual(opt.funcVoxelDims, [1 1 1]);
  assertEqual(opt.someExtraField, 'test');

end

function test_checkOptionsErrorTask()

  opt.taskName = [];
  opt.verbosity = 1;

  assertWarning( ...
                @()checkOptions(opt), ...
                'checkOptions:noTask');

end

function test_checkOptionsErrorGroup()

  opt.groups = {1};

  assertExceptionThrown( ...
                        @()checkOptions(opt), ...
                        'checkOptions:groupNotString');

end

function test_checkOptionsErrorRefSlice()

  opt.STC_referenceSlice = [1:10];

  assertExceptionThrown( ...
                        @()checkOptions(opt), ...
                        'checkOptions:refSliceNotScalar');

end

function test_checkOptionsErrorVoxDim()

  opt.funcVoxelDims = [1:10];

  assertExceptionThrown( ...
                        @()checkOptions(opt), ...
                        'checkOptions:voxDim');

end

function test_checkOptionsSessionString()

  opt.anatReference.session = 1;

  assertExceptionThrown( ...
                        @()checkOptions(opt), ...
                        'checkOptions:sessionNotString');

end
