% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_returnDependency %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_returnDependency_basic()

  spm_jobman('initcfg');

  opt.orderBatches.selectAnat = 1;
  opt.orderBatches.segment = 5;
  opt.orderBatches.skullStripping = 6;
  opt.orderBatches.coregister = 7;
  opt.orderBatches.realign = 10;

  dep = returnDependency(opt, 'segment');
  expected = substruct('.', 'val', '{}', {5}, ...
                       '.', 'val', '{}', {1}, ...
                       '.', 'val', '{}', {1});
  assertEqual(dep, expected);

  dep = returnDependency(opt, 'skullStripping');
  expected = substruct('.', 'val', '{}', {6}, ...
                       '.', 'val', '{}', {1}, ...
                       '.', 'val', '{}', {1});
  assertEqual(dep, expected);

  dep = returnDependency(opt, 'coregister');
  expected = substruct('.', 'val', '{}', {7}, ...
                       '.', 'val', '{}', {1}, ...
                       '.', 'val', '{}', {1}, ...
                       '.', 'val', '{}', {1});
  assertEqual(dep, expected);

  dep = returnDependency(opt, 'selectAnat');
  expected = substruct('.', 'val', '{}', {1}, ...
                       '.', 'val', '{}', {1}, ...
                       '.', 'val', '{}', {1}, ...
                       '.', 'val', '{}', {1});
  assertEqual(dep, expected);

  dep = returnDependency(opt, 'realign');
  expected = substruct('.', 'val', '{}', {10}, ...
                       '.', 'val', '{}', {1}, ...
                       '.', 'val', '{}', {1}, ...
                       '.', 'val', '{}', {1});
  assertEqual(dep, expected);
end
