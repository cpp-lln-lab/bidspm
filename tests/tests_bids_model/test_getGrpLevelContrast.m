% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_getGrpLevelContrast %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getGrpLevelContrast_basic()

  opt.model.file = fullfile(getDummyDataDir(), 'models', 'model-vismotion_smdl.json');

  [grpLvlCon, iNode] = getGrpLevelContrast(opt);

  DummyContrasts = struct('Test', 't', ...
                    'Contrasts', {{
                   'trial_type.VisMot'; ...
                   'trial_type.VisStat'; ...
                   'VisMot_gt_VisStat'; ...
                   'VisStat_gt_VisMot'}});

  assertEqual(iNode, 3);
  assertEqual(grpLvlCon, DummyContrasts);

  %%
  opt.model.file = fullfile(getDummyDataDir(), 'models', 'model-vislocalizer_smdl.json');

  [grpLvlCon, iNode] = getGrpLevelContrast(opt);

  DummyContrasts = struct('Test', 't', ...
                    'Contrasts', {{
                   'trial_type.VisMot'; ...
                   'trial_type.VisStat'; ...
                   'VisMot_gt_VisStat'; ...
                   'VisStat_gt_VisMot'}});

  assertEqual(iNode, 3);
  assertEqual(grpLvlCon, DummyContrasts);

end
