function test_suite = test_getContrastNb %#ok<*STOUT>
  % (C) Copyright 2022 CPP_SPM developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getContrastNb_basic()

  %% GIVEN

  opt = setTestCfg();

  result.dir = pwd;
  result.name = 'bar';

  result.name = regexify(result.name);

  SPM.xCon(1, 1).name = 'foo';
  SPM.xCon(2, 1).name = 'bar';
  SPM.xCon(3, 1).name = 'foobar';

  %% WHEN
  contrastNb = getContrastNb(result, opt, SPM);

  %% THEN
  assertEqual(contrastNb, 2);

end

function test_getContrastNb_missing()

  if isOctave
    return
  end

  %% GIVEN

  opt = setTestCfg();

  result.dir = pwd;
  result.name = 'rab';

  result.name = regexify(result.name);

  SPM.xCon(1, 1).name = 'foo';
  SPM.xCon(2, 1).name = 'bar';
  SPM.xCon(3, 1).name = 'foobar';

  %% THEN
  assertWarning(@()getContrastNb(result, opt, SPM), 'getContrastNb:noMatchingContrastName');

end

function test_getContrastNb_no_name()

  if isOctave
    return
  end

  %% GIVEN

  opt = setTestCfg();

  result.dir = pwd;
  result.name = '';

  result.name = regexify(result.name);

  SPM.xCon(1, 1).name = 'foo';
  SPM.xCon(2, 1).name = 'bar';
  SPM.xCon(3, 1).name = 'foobar';

  %% THEN
  assertWarning(@()getContrastNb(result, opt, SPM), 'getContrastNb:missingContrastName');

end
