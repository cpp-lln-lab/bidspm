% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_createEmptyStatsModel %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_createEmptyStatsModel_basic()

  % skip test in CI
  if isGithubCi
    return
  end

  content = createEmptyStatsModel();

  %   bids.util.jsonencode(fullfile(pwd, 'model-empty_smdl.json'), content);

  expectedContent = spm_jsonread(fullfile(getDummyDataDir(), 'models', 'model-empty_smdl.json'));

  assertEqual(fieldnames(content), fieldnames(expectedContent));
  assertEqual(content.Nodes{3}.Model, expectedContent.Nodes{3}.Model);
  assertEqual(content.Nodes{3}, expectedContent.Nodes{3});
  assertEqual(content.Nodes{2}.Model, expectedContent.Nodes{2}.Model);
  assertEqual(content.Nodes{2}, expectedContent.Nodes{2});
  assertEqual(content.Nodes{1}.Model, expectedContent.Nodes{1}.Model);
  assertEqual(content.Nodes{1}, expectedContent.Nodes{1});

  fields = fieldnames(expectedContent);
  for i = 1:numel(fields)
    %     disp(expectedContent.(fields{i}));
    %     disp(content.(fields{i}));
    assertEqual(content.(fields{i}), expectedContent.(fields{i}));
  end
  assertEqual(content, expectedContent);

end
