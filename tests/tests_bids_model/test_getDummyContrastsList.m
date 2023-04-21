function test_suite = test_getDummyContrastsList %#ok<*STOUT>

  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getDummyContrastsList_bug_815()

  model_file = fullfile(getTestDataDir(), 'models', 'model-bug815_smdl.json');
  model = bids.Model('file', model_file, 'verbose', false);

  nodeName = 'subject_level';

  dummyContrastsList = getDummyContrastsList(nodeName, model);

  assertEqual(numel(dummyContrastsList), 7);

end

function test_getDummyContrastsList_wrong_level()

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');
  opt.model.bm.verbose = false;

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
