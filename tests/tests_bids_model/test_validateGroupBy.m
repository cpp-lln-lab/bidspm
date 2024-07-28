% (C) Copyright 2022 bidspm developers

function test_suite = test_validateGroupBy %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_validateGroupBy_run()

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');

  bm = BidsModel('file', opt.model.file);
  bm.verbose = false;
  node = bm.Nodes{1};

  node.GroupBy = {'subject'};
  assertWarning(@()bm.validateGroupBy(node), 'BidsModel:notImplemented');

  node.GroupBy = {'run', 'dataset'};
  bm.Nodes{1} = node;
  assertWarning(@()bm.validateGroupBy(node.Name), 'BidsModel:notImplemented');

end

function test_validateGroupBy_subject()

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');
  bm = BidsModel('file', opt.model.file);
  bm.verbose = false;
  node = bm.Nodes{2};

  node.GroupBy = {'subject'};
  assertWarning(@()bm.validateGroupBy(node), 'BidsModel:notImplemented');

  node.GroupBy = {'session', 'subject'};
  assertWarning(@()bm.validateGroupBy(node), 'BidsModel:notImplemented');
end

function test_checkGroupBy_dataset()

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');

  bm = BidsModel('file', opt.model.file);
  bm.verbose = false;

  % should be fine
  node = bm.Nodes{3};
  node.GroupBy = {'contrast'};
  status = bm.validateGroupBy(node);
  assertEqual(status, true);

  node.GroupBy = {'subject'};
  assertWarning(@()bm.validateGroupBy(node), 'BidsModel:notImplemented');

  node.GroupBy = {'session', 'subject'};
  assertWarning(@()bm.validateGroupBy(node), 'BidsModel:notImplemented');

  node.GroupBy = {'session', 'subject', 'foo'};
  assertWarning(@()bm.validateGroupBy(node), 'BidsModel:notImplemented');

end

function test_checkGroupBy_dataset_group_from_participant()

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');

  bm = BidsModel('file', opt.model.file);
  bm.verbose = false;

  bm.Nodes{3}.GroupBy = {'contrast', 'diagnostic'};
  bm.validateGroupBy(bm.Nodes{3}, {'diagnostic'});

end
