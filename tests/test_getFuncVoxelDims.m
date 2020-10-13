function test_suite = test_getFuncVoxelDims %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_getFuncVoxelDimsBasic()

    opt.funcVoxelDims = [];

    subFuncDataDir = fullfile(fileparts(mfilename('fullpath')), '..', 'demos', ...
                              'MoAE', 'output', 'MoAEpilot', 'sub-01', 'func');

    prefix = '';

    fileName = 'sub-01_task-auditory_bold.nii';

    [voxDim, opt] = getFuncVoxelDims(opt, subFuncDataDir, prefix, fileName);

    expectedVoxDim = [3 3 3];
    assertEqual(voxDim, expectedVoxDim);

    expectedOpt.funcVoxelDims = [3 3 3];
    assertEqual(opt, expectedOpt);

end

function test_getFuncVoxelDimsForce()

    opt.funcVoxelDims = [1 1 1];

    subFuncDataDir = fullfile(fileparts(mfilename('fullpath')), '..', 'demos', ...
                              'output', 'MoAEpilot', 'sub-01', 'func');

    prefix = '';

    fileName = 'sub-01_task-auditory_bold.nii';

    voxDim = getFuncVoxelDims(opt, subFuncDataDir, prefix, fileName);

    expectedVoxDim = [1 1 1];
    assertEqual(voxDim, expectedVoxDim);

end
