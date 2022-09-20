% (C) Copyright 2020 bidspm developers

function test_suite = test_getFuncVoxelDims %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getFuncVoxelDims_basic()

  opt.funcVoxelDims = [];

  subFuncDataDir = fullfile(getMoaeDir(), 'inputs', 'raw', 'sub-01', 'func');

  fileName = 'sub-01_task-auditory_bold.nii';

  [voxDim, opt] = getFuncVoxelDims(opt, subFuncDataDir, fileName);

  expectedVoxDim = [3 3 3];
  assertEqual(voxDim, expectedVoxDim);

  expectedOpt.funcVoxelDims = [3 3 3];
  assertEqual(opt, expectedOpt);

end

function test_getFuncVoxelDims_force()

  opt.funcVoxelDims = [1 1 1];

  subFuncDataDir = 'could be anything';

  fileName = 'sub-01_task-auditory_bold.nii';

  voxDim = getFuncVoxelDims(opt, subFuncDataDir, fileName);

  expectedVoxDim = [1 1 1];
  assertEqual(voxDim, expectedVoxDim);

end
