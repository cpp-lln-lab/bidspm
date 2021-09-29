% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_specifyContrasts %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_specifyContrastsVismotion()
  %
  % Note requires an SPM.mat to run
  %

  % GIVEN
  subLabel = '01';
  funcFWHM = 6;

  opt = setOptions('vismotion', subLabel);

  ffxDir = getFFXdir(subLabel, funcFWHM, opt);

  % WHEN
  contrasts = specifyContrasts(ffxDir, opt.taskName, opt);

  % THEN
  expected.name = 'VisMot'; %#ok<*AGROW>
  expected.C = [1 0 0 0 0 0 0 0 0];

  expected(2).name = 'VisStat';
  expected(2).C = [0 1 0 0 0 0 0 0 0];

  expected(3).name = 'VisMot_gt_VisStat';
  expected(3).C = [1 -1 0 0 0 0 0 0 0];

  expected(4).name = 'VisStat_gt_VisMot';
  expected(4).C = [-1 1 0 0 0 0 0 0 0];

  assertEqual(contrasts, expected);

end

function test_specifyContrastsVislocalizer()
  %
  % Note requires an SPM.mat to run
  %

  % GIVEN
  subLabel = '01';
  funcFWHM = 6;

  opt = setOptions('vislocalizer', subLabel);

  ffxDir = getFFXdir(subLabel, funcFWHM, opt);

  % WHEN
  contrasts = specifyContrasts(ffxDir, opt.taskName, opt);

  % THEN
  expected.name = 'VisMot_1';
  expected.C = [1 0 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisMot_&_VisStat_1';
  expected(end).C = [1 1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisMot';
  expected(end).C = [1 0 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisStat';
  expected(end).C = [0 1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisMot_gt_VisStat';
  expected(end).C = [1 -1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisStat_gt_VisMot';
  expected(end).C = [-1 1 0 0 0 0 0 0 0];

  assertEqual(contrasts, expected);

end
