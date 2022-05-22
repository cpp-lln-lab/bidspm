function test_suite = test_getDummyContrastsList %#ok<*STOUT>
  % (C) Copyright 2022 CPP_SPM developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getDummyContrastsList_wrong_level()

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');

  nodeName = 'foo_level';

  dummyContrastsList = getDummyContrastsList(nodeName, opt.model.bm);

  assert(isempty(dummyContrastsList));

end

function test_getDummyContrastsList_basic()

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');

  opt.model.bm.Nodes{3}.DummyContrasts.Contrasts = {'foo', 'bar', 'foobar'};

  nodeName = 'dataset_level';

  dummyContrastsList = getDummyContrastsList(nodeName, opt.model.bm);

  assertEqual(dummyContrastsList, {'foo', 'bar', 'foobar'});

end

function test_getDummyContrastsList_from_lower_levels()

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');

  nodeName = 'dataset_level';

  dummyContrastsList = getDummyContrastsList(nodeName, opt.model.bm);

  assertEqual(dummyContrastsList, {'VisMot'
                                   'VisStat'});

end
