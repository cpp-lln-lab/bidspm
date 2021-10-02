% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_createDefaultModel %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_createDefaultModel_basic()

  useRaw = true;
  opt = setOptions('vislocalizer', '', useRaw);

  [BIDS, opt] = getData(opt, opt.dir.preproc);

  createDefaultModel(BIDS, opt);

  % make sure the file was created where expected
  expectedFileName = fullfile(pwd, 'models', 'model-defaultVislocalizer_smdl.json');
  assertEqual(exist(expectedFileName, 'file'), 2);

  % check it has the right content
  content = spm_jsonread(expectedFileName);

  expectedContent = spm_jsonread(fullfile(getDummyDataDir(), 'models', 'model-default_smdl.json'));

  assertEqual(content.Steps{1}, expectedContent.Steps{1});
  assertEqual(content.Steps{2}, expectedContent.Steps{2});
  assertEqual(content.Steps{3}, expectedContent.Steps{3});

  cleanUp(fullfile(pwd, 'models'));

end
