function test_suite = test_groupLevelGlmType %#ok<*STOUT>
  % (C) Copyright 2023 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_groupLevelGlmType_basic()

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');

  model = opt.model.bm;
  model.Nodes{3}.GroupBy = {'contrast', 'group'};
  type = model.groupLevelGlmType('dataset_level');
  assertEqual(type, 'one_sample_t_test');

  model.Nodes{3}.Model.X = {1, 'group'};
  type = model.groupLevelGlmType('dataset_level');
  assertEqual(type, 'unknown');

  model.Nodes{3}.Model.X = {1, 'diagnostic'};
  participants = struct('participant_id', {{'01', '02'}}, ...
                        'diagnostic', {{'ctrl', 'ctrl'}});
  type = model.groupLevelGlmType('dataset_level', participants);
  assertEqual(type, 'one_sample_t_test');

  model.Nodes{3}.Model.X = {1, 'diagnostic'};
  participants = struct('participant_id', {{'01', '02'}}, ...
                        'diagnostic', {{'ctrl', 'patient'}});
  type = model.groupLevelGlmType('dataset_level', participants);
  assertEqual(type, 'two_sample_t_test');

  model.Nodes{3}.Model.X = {1, 'group'};
  participants = struct('participant_id', {{'01', '02'}}, ...
                        'diagnostic', {{'ctrl', 'patient'}});
  type = model.groupLevelGlmType('dataset_level', participants);
  assertEqual(type, 'unknown');

  model.Nodes{3}.Model.X = {1, 'group'};
  participants = struct('participant_id', {{'01', '02'}}, ...
                        'group', {{'ctrl', 'patient', 'relative'}});
  type = model.groupLevelGlmType('dataset_level', participants);
  assertEqual(type, 'one_way_anova');

end
