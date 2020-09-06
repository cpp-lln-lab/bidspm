function test_suite = test_getPrefix %#ok<*STOUT>
    try % assignment of 'localfunctions' is necessary in Matlab >= 2016
        test_functions = localfunctions(); %#ok<*NASGU>
    catch % no problem; early Matlab versions can use initTestSuite fine
    end
    initTestSuite;
end

function test_getPrefixSTC()

    step = 'STC';
    funcFWHM = 6;
    opt.metadata.SliceTiming = 1:0.2:1.8;
    opt.sliceOrder = 1:10;

    expectedPrefxOutput = '';
    expectedMotionRegressorPrefix = '';

    [prefix, motionRegressorPrefix] = getPrefix(step, opt, funcFWHM);

    assertEqual(expectedPrefxOutput, prefix);
    assertEqual(expectedMotionRegressorPrefix, motionRegressorPrefix);

end

function test_getPrefixPreprocess()

    step = 'preprocess';
    funcFWHM = 6;
    opt.metadata.SliceTiming = 1:0.2:1.8;
    opt.sliceOrder = 1:10;

    expectedPrefxOutput = spm_get_defaults('slicetiming.prefix');
    expectedMotionRegressorPrefix = '';

    [prefix, motionRegressorPrefix] = getPrefix(step, opt, funcFWHM);

    assertEqual(expectedPrefxOutput, prefix);
    assertEqual(expectedMotionRegressorPrefix, motionRegressorPrefix);

end

function test_getPrefixPreprocessNoSTC()

    step = 'preprocess';
    funcFWHM = 6;
    opt.metadata = [];
    opt.sliceOrder = [];

    expectedPrefxOutput = '';
    expectedMotionRegressorPrefix = '';

    [prefix, motionRegressorPrefix] = getPrefix(step, opt, funcFWHM);

    assertEqual(expectedPrefxOutput, prefix);
    assertEqual(expectedMotionRegressorPrefix, motionRegressorPrefix);

end

function test_getPrefixSmoothing()

    step = 'smoothing';
    funcFWHM = 6;
    opt.metadata = [];
    opt.sliceOrder = [];

    expectedPrefxOutput = spm_get_defaults('normalise.write.prefix');
    expectedMotionRegressorPrefix = '';

    [prefix, motionRegressorPrefix] = getPrefix(step, opt, funcFWHM);

    assertEqual(expectedPrefxOutput, prefix);
    assertEqual(expectedMotionRegressorPrefix, motionRegressorPrefix);

end

function test_getPrefixSmoothingT1w()

    step = 'smoothing_space-T1w';
    funcFWHM = 6;
    opt.metadata = [];
    opt.sliceOrder = [];

    expectedPrefxOutput = spm_get_defaults('realign.write.prefix');
    expectedMotionRegressorPrefix = '';

    [prefix, motionRegressorPrefix] = getPrefix(step, opt, funcFWHM);

    assertEqual(expectedPrefxOutput, prefix);
    assertEqual(expectedMotionRegressorPrefix, motionRegressorPrefix);

end

function test_getPrefixFFX()

    step = 'FFX';
    funcFWHM = 6;
    opt.metadata = [];
    opt.sliceOrder = [];

    expectedPrefxOutput = [ ...
        spm_get_defaults('smooth.prefix'), ...
        num2str(funcFWHM), ...
        spm_get_defaults('normalise.write.prefix')];
    expectedMotionRegressorPrefix = '';

    [prefix, motionRegressorPrefix] = getPrefix(step, opt, funcFWHM);

    assertEqual(expectedPrefxOutput, prefix);
    assertEqual(expectedMotionRegressorPrefix, motionRegressorPrefix);

end

function test_getPrefixFFXT1w()

    step = 'FFX_space-T1w';
    funcFWHM = 6;
    opt.metadata = [];
    opt.sliceOrder = [];

    expectedPrefxOutput = [ ...
        spm_get_defaults('smooth.prefix'), ...
        num2str(funcFWHM), ...
        spm_get_defaults('realign.write.prefix')];
    expectedMotionRegressorPrefix = '';

    [prefix, motionRegressorPrefix] = getPrefix(step, opt, funcFWHM);

    assertEqual(expectedPrefxOutput, prefix);
    assertEqual(expectedMotionRegressorPrefix, motionRegressorPrefix);

end

function test_getPrefixError()

    step = 'error';
    funcFWHM = 6;
    opt.metadata = [];
    opt.sliceOrder = [];

    assertExceptionThrown( ...
        @()getPrefix(step, opt, funcFWHM), ...
        'getPrefix:unknownPrefixCase');

end
