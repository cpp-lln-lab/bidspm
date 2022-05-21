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

  % unfoldStruct(opt);

end

function test_checkOptions_results_structure()

  opt.taskName = 'testTask';
  opt.result.contrasts(1).nodeName = 'run_level';
  opt.result.contrasts(1).name = 'listening_1';
  opt.result.contrasts(1).MC = 'none';
  opt.result.contrasts(1).p = 0.001;
  opt.result.contrasts(2).nodeName = 'run_level';
  opt.result.contrasts(2).name = 'not_listening_1';
  opt.result.contrasts(3).nodeName = 'subject_level';
  opt.result.contrasts(3).name = 'listening_1';
  opt = checkOptions(opt);

  assertEqual(opt.result.contrasts(2).MC, 'FWE');
  assertEqual(opt.result.contrasts(2).p, 0.05);

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

  if isOctave
    return
  end

  opt.taskName = '';
  opt.verbosity = 1;

  assertWarning(@()checkOptions(opt), 'checkOptions:noTask');

end

function test_checkOptions_error_group()

  opt.groups = {1};

  assertExceptionThrown(@()checkOptions(opt), 'checkOptions:groupNotString');

end

function test_checkOptions_error_ref_slice()

  opt.stc.referenceSlice = [1:10];
  opt.taskName = 'testTask';

  assertExceptionThrown(@()checkOptions(opt), 'checkOptions:refSliceNotScalar');

end

function test_checkOptions_error_vox_dim()

  opt.funcVoxelDims = [1:10];

  assertExceptionThrown(@()checkOptions(opt), 'checkOptions:voxDim');

end
