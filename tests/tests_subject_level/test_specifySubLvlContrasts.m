function test_suite = test_specifySubLvlContrasts %#ok<*STOUT>
  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_specifySubLvlContrasts_basic()

  contrasts = struct('C', [], 'name', []);
  counter = 0;

  node.Contrasts{1} = struct('Name', 'french_gt_scrambled', ...
                             'ConditionList', {{'trial_type.fw', 'trial_type.sfw'}}, ...
                             'Weights', [1 -1], ...
                             'Test', 't');
  node.Level = 'subject';
  node.Model.X = 1;

  SPM.xX.X = rand(6, 2);
  SPM.xX.name = {'Sn(1) fw*bf(1)', 'Sn(1) sfw*bf(1)'};

  [contrasts, counter] = specifySubLvlContrasts(contrasts, node, counter, SPM);

  assertEqual(counter, 1);
  assertEqual(contrasts.C, [1 -1]);
  assertEqual(contrasts.name, 'french_gt_scrambled');

end
