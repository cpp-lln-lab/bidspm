function test_suite = test_getContrastsList %#ok<*STOUT>
  % (C) Copyright 2022 CPP_SPM developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getContrastsList_wrong_level()

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');

  nodeName = 'foo_level';

  contrastsList = getContrastsList(nodeName, opt.model.bm);

  assert(isempty(contrastsList));

end

function test_getContrastsList_basic()

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');

  opt.model.bm.Nodes{3}.Contrasts(1).Name = 'foo';
  opt.model.bm.Nodes{3}.Contrasts(1).ConditionList = {'foo'};
  opt.model.bm.Nodes{3}.Contrasts(1).Weights = -1;

  nodeName = 'dataset_level';

  contrastsList = getContrastsList(nodeName, opt.model.bm);

  assertEqual(contrastsList{1}.Name, 'foo');

end

function test_getContrastsList_from_lower_levels()

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');

  nodeName = 'dataset_level';

  contrastsList = getContrastsList(nodeName, opt.model.bm);

  assertEqual(contrastsList{1}.Name, 'VisMot_gt_VisStat');
  assertEqual(contrastsList{2}.Name, 'VisStat_gt_VisMot');

end
