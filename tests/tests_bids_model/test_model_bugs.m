% (C) Copyright 2020 bidspm developers

function test_suite = test_model_bugs %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_model_bug_616()

  % https://github.com/cpp-lln-lab/CPP_SPM/issues/616

  opt.model.file = fullfile(getDummyDataDir(), 'models', 'model-bug616_smdl.json');

  bm = BidsModel('file', opt.model.file);

  assertEqual(numel(bm.Nodes{3}.Contrasts), 1);

end

function test_model_bug_385()

  % https://github.com/bids-standard/bids-matlab/issues/385

  opt.model.file = fullfile(getDummyDataDir(), 'models', 'model-bug385_smdl.json');

  bm = BidsModel('file', opt.model.file);
  bm.getRootNode;

  nodeName = 'dataset';
  contrastsList = getContrastsList(nodeName, bm);
  dummyContrastsList = getDummyContrastsList(nodeName, bm);

end
