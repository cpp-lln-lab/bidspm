% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_createEmptyStatsModel %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_createEmptyStatsModel_basic()

  content = createEmptyStatsModel();
  
%   bids.util.jsonencode(fullfile(pwd, 'model-empty_smdl.json'), content);

  expectedContent = spm_jsonread(fullfile(getDummyDataDir(), 'models', 'model-empty_smdl.json'));

  assertEqual(fieldnames(content), fieldnames(expectedContent));
  assertEqual(content, expectedContent);

end
