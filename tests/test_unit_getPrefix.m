% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_unit_getPrefix %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getPrefixNormalise()

  step = 'normalise';

  opt = setOptions('dummy');

  opt.metadata = [];
  opt.sliceOrder = [];
  opt.realign.useUnwarp = true;
  opt.space = 'MNI';

  prefix = getPrefix(step, opt);

  expectedPrefixOutput = spm_get_defaults('unwarp.write.prefix');

  assertEqual(prefix, expectedPrefixOutput);

  %% no unwarp

  step = 'normalise';

  opt = setOptions('dummy');

  opt.metadata = [];
  opt.sliceOrder = [];
  opt.realign.useUnwarp = false;
  opt.space = 'MNI';

  prefix = getPrefix(step, opt);

  expectedPrefixOutput = '';

  assertEqual(prefix, expectedPrefixOutput);

end

function test_getPrefixSmooth()

  step = 'smooth';

  opt = setOptions('dummy');

  opt.metadata = [];
  opt.sliceOrder = [];
  opt.realign.useUnwarp = true;
  opt.space = 'MNI';

  prefix = getPrefix(step, opt);

  expectedPrefixOutput = [ ...
                          spm_get_defaults('normalise.write.prefix'), ...
                          spm_get_defaults('unwarp.write.prefix')];

  assertEqual(prefix, expectedPrefixOutput);

  %% with STC
  opt.metadata.SliceTiming = 1:0.2:1.8;
  opt.sliceOrder = 1:10;
  opt.realign.useUnwarp = true;
  opt.space = 'MNI';

  prefix = getPrefix(step, opt);

  expectedPrefixOutput = [ ...
                          spm_get_defaults('normalise.write.prefix'), ...
                          spm_get_defaults('unwarp.write.prefix')];

  assertEqual(prefix, expectedPrefixOutput);

  %% native space
  opt.metadata = [];
  opt.sliceOrder = [];
  opt.realign.useUnwarp = true;
  opt.space = 'individual';

  prefix = getPrefix(step, opt);

  expectedPrefixOutput = spm_get_defaults('unwarp.write.prefix');

  assertEqual(prefix, expectedPrefixOutput);

  %% native space no unwarp
  opt.realign.useUnwarp = false;
  opt.space = 'individual';

  prefix = getPrefix(step, opt);

  expectedPrefixOutput = spm_get_defaults('realign.write.prefix');

  assertEqual(prefix, expectedPrefixOutput);

  %% MNI space no unwarp
  opt.realign.useUnwarp = false;
  opt.space = 'MNI';

  prefix = getPrefix(step, opt);

  expectedPrefixOutput = spm_get_defaults('normalise.write.prefix');

  assertEqual(prefix, expectedPrefixOutput);

end

function test_getPrefixFFX()

  step = 'FFX';
  funcFWHM = 6;

  opt = setOptions('dummy');

  opt.metadata = [];
  opt.sliceOrder = [];
  opt.realign.useUnwarp = true;
  opt.space = 'MNI';

  [prefix, motionRegressorPrefix] = getPrefix(step, opt, funcFWHM);

  expectedPrefixOutput = sprintf('%s%i%s%s', ...
                                 spm_get_defaults('smooth.prefix'), ...
                                 funcFWHM, ...
                                 spm_get_defaults('normalise.write.prefix'), ...
                                 spm_get_defaults('unwarp.write.prefix'));
  expectedMotionRegressorPrefix = '';

  assertEqual(prefix, expectedPrefixOutput);
  assertEqual(motionRegressorPrefix, expectedMotionRegressorPrefix);

  %% native space
  opt.realign.useUnwarp = true;
  opt.space = 'individual';

  [prefix, motionRegressorPrefix] = getPrefix(step, opt, funcFWHM);

  expectedPrefixOutput = sprintf('%s%i%s', ...
                                 spm_get_defaults('smooth.prefix'), ...
                                 funcFWHM, ...
                                 spm_get_defaults('unwarp.write.prefix'));
  expectedMotionRegressorPrefix = '';

  assertEqual(prefix, expectedPrefixOutput);
  assertEqual(motionRegressorPrefix, expectedMotionRegressorPrefix);

  %% STC, native space no unwarp
  opt.realign.useUnwarp = false;
  opt.space = 'individual';
  opt.metadata.SliceTiming = 1:0.2:1.8;
  opt.sliceOrder = 1:10;

  [prefix, motionRegressorPrefix] = getPrefix(step, opt, funcFWHM);

  expectedPrefixOutput = sprintf('%s%i%s%s', ...
                                 spm_get_defaults('smooth.prefix'), ...
                                 funcFWHM, ...
                                 spm_get_defaults('realign.write.prefix'));
  expectedMotionRegressorPrefix = '';

  assertEqual(prefix, expectedPrefixOutput);
  assertEqual(motionRegressorPrefix, 'a');

  %% MNI space no unwarp
  opt.realign.useUnwarp = false;
  opt.space = 'MNI';
  opt.metadata = [];
  opt.sliceOrder = [];

  [prefix] = getPrefix(step, opt, funcFWHM);

  expectedPrefixOutput = sprintf('%s%i%s%s', ...
                                 spm_get_defaults('smooth.prefix'), ...
                                 funcFWHM, ...
                                 spm_get_defaults('normalise.write.prefix'));
  expectedMotionRegressorPrefix = '';

  assertEqual(prefix, expectedPrefixOutput);

end

function test_getPrefixError()

  step = 'error';
  funcFWHM = 6;

  opt = setOptions('dummy');

  opt.metadata = [];
  opt.sliceOrder = [];

  assertExceptionThrown( ...
                        @()getPrefix(step, opt, funcFWHM), ...
                        'getPrefix:unknownPrefixCase');

end
