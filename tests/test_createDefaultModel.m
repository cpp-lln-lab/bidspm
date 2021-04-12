% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function test_suite = test_createDefaultModel %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_createDefaultModelBasic()

  opt = setOptions('vislocalizer');

  [BIDS, opt] = getData(opt);

  createDefaultModel(BIDS, opt);

  % make sure the file was created where expected
  expectedFileName = fullfile(pwd, 'models', 'model-defaultVislocalizer_smdl.json');
  assertEqual(exist(expectedFileName, 'file'), 2);

  % check it has the right content
  content = spm_jsonread(expectedFileName);
  expectedContent = spm_jsonread(fullfile(fileparts(mfilename('fullpath')), ...
                                          'dummyData', ...
                                          'models', ...
                                          'model-default_smdl.json'));

  assertEqual(content.Steps, expectedContent.Steps);

end
