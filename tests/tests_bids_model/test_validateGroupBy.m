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
  nodeName = bm.Nodes{1}.Name;

  bm.Nodes{1}.GroupBy = {'subject'};
  assertWarning(@()bm.validateGroupBy(nodeName), 'BidsModel:notImplemented');

  bm.Nodes{1}.GroupBy = {'run', 'dataset'};
  assertWarning(@()bm.validateGroupBy(nodeName), 'BidsModel:notImplemented');

end

function test_validateGroupBy_subject()

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');
  bm = BidsModel('file', opt.model.file);
  bm.verbose = false;
  nodeName = bm.Nodes{2}.Name;

  bm.Nodes{2}.GroupBy = {'subject'};
  assertWarning(@()bm.validateGroupBy(nodeName), 'BidsModel:notImplemented');

  bm.Nodes{2}.GroupBy = {'session', 'subject'};
  assertWarning(@()bm.validateGroupBy(nodeName), 'BidsModel:notImplemented');
end

function test_validateGroupBy_dataset()

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');

  bm = BidsModel('file', opt.model.file);
  bm.verbose = false;
  nodeName = bm.Nodes{3}.Name;

  % should be fine
  bm.Nodes{3}.GroupBy = {'contrast'};
  status = bm.validateGroupBy(nodeName);
  assertEqual(status, true);

  bm.Nodes{3}.GroupBy = {'subject'};
  assertWarning(@()bm.validateGroupBy(nodeName), 'BidsModel:notImplemented');

  bm.Nodes{3}.GroupBy = {'session', 'subject'};
  assertWarning(@()bm.validateGroupBy(nodeName), 'BidsModel:notImplemented');

  bm.Nodes{3}.GroupBy = {'session', 'subject', 'foo'};
  assertWarning(@()bm.validateGroupBy(nodeName), 'BidsModel:notImplemented');

end

function test_validateGroupBy_dataset_group_from_participant()

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');

  bm = BidsModel('file', opt.model.file);
  bm.verbose = false;
  nodeName = bm.Nodes{3}.Name;

  bm.Nodes{3}.GroupBy = {'contrast', 'diagnostic'};
  bm.validateGroupBy(nodeName, struct('diagnostic', {{'foo', 'bar'}}));

end
