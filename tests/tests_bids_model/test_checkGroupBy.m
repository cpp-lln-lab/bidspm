% (C) Copyright 2022 bidspm developers

function test_suite = test_checkGroupBy %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_checkGroupBy_run()

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');

  opt.model.bm.Nodes{1}.GroupBy = {'subject'};

  assertWarning(@()checkGroupBy(opt.model.bm.Nodes{1}), ...
                'checkGroupBy:notImplemented');

  opt.model.bm.Nodes{1}.GroupBy = {'run', 'dataset'};

  assertWarning(@()checkGroupBy(opt.model.bm.Nodes{1}), ...
                'checkGroupBy:notImplemented');

end

function test_checkGroupBy_subject()

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');

  opt.model.bm.Nodes{2}.GroupBy = {'subject'};

  assertWarning(@()checkGroupBy(opt.model.bm.Nodes{2}), ...
                'checkGroupBy:notImplemented');

  opt.model.bm.Nodes{2}.GroupBy = {'session', 'subject'};

  assertWarning(@()checkGroupBy(opt.model.bm.Nodes{2}), ...
                'checkGroupBy:notImplemented');

end

function test_checkGroupBy_dataset()

  opt = setOptions('vismotion', {'01' 'ctrl01'}, 'pipelineType', 'stats');

  opt.model.bm.Nodes{3}.GroupBy = {'subject'};

  assertWarning(@()checkGroupBy(opt.model.bm.Nodes{3}), ...
                'checkGroupBy:notImplemented');

  opt.model.bm.Nodes{3}.GroupBy = {'session', 'subject'};

  assertWarning(@()checkGroupBy(opt.model.bm.Nodes{3}), ...
                'checkGroupBy:notImplemented');

end
