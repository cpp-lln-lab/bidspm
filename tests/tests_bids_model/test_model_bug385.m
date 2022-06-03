% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_model_bug385 %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_model_bug385_basic()

  opt.model.file = fullfile(getDummyDataDir(), 'models', 'model-bug385_smdl.json');

  bm = BidsModel('file', opt.model.file);
  bm.getRootNode;

  nodeName = 'dataset';
  contrastsList = getContrastsList(nodeName, bm);
  dummyContrastsList = getDummyContrastsList(nodeName, bm);

end
