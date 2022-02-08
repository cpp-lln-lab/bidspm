% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_unit_getGrpLevelContrastToCompute %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getGrpLevelContrastToComputeBasic()

  opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                            'dummyData', 'models', 'model-vismotion_smdl.json');

  [grpLvlCon, iStep] = getGrpLevelContrastToCompute(opt);

  AutoContrasts = {
                   'trial_type.VisMot'; ...
                   'trial_type.VisStat'; ...
                   'VisMot_gt_VisStat'; ...
                   'VisStat_gt_VisMot'};

  assertEqual(iStep, 2);
  assertEqual(grpLvlCon, AutoContrasts);

  %%
  opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                            'dummyData', 'models', 'model-vislocalizer_smdl.json');

  [grpLvlCon, iStep] = getGrpLevelContrastToCompute(opt);

  AutoContrasts = {
                   'trial_type.VisMot'; ...
                   'trial_type.VisStat'; ...
                   'VisMot_gt_VisStat'; ...
                   'VisStat_gt_VisMot'};

  assertEqual(iStep, 3);
  assertEqual(grpLvlCon, AutoContrasts);

end
