function test_suite = test_bidspm_default_stats_model %#ok<*STOUT>

  % (C) Copyright 2023 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_createDefaultStatsModel_CLI()

  markTestAs('slow');

  outputPath = tempName();

  opt = setOptions('vislocalizer', '');

  bidspm(opt.dir.input, outputPath, 'dataset', ...
         'action', 'default_model', ...
         'task', {'vislocalizer', 'vismotion'}, ...
         'space', {'individual'}, ...
         'verbosity', 0, ...
         'skip_validation', true);

  % make sure the file was created where expected
  expectedFilename = fullfile(outputPath, 'derivatives', 'models', ...
                              'model-defaultVislocalizerVismotion_smdl.json');
  assertEqual(exist(expectedFilename, 'file'), 2);

  % check it has the right content
  content = spm_jsonread(expectedFilename);

  expectedContent = spm_jsonread(fullfile(getTestDataDir(), 'models', 'model-default_smdl.json'));
  expectedContent.Input.task = {'vislocalizer'; 'vismotion'};
  expectedContent.Input.space = {'individual'};

  if ~bids.internal.is_github_ci()
    for i = 1:numel(content.Nodes)
      tmp = fieldnames(content.Nodes{i});
      for j = 1:numel(tmp)
        assertEqual(content.Nodes{i}.(tmp{j}), ...
                    expectedContent.Nodes{i}.(tmp{j}));
      end
    end

    assertEqual(content.Edges, expectedContent.Edges);
    assertEqual(content.Input, expectedContent.Input);
  end

end

function test_createDefaultStatsModel_CLI_ignore()

  markTestAs('slow');

  outputPath = tempName();

  opt = setOptions('vislocalizer', '');

  bidspm(opt.dir.input, outputPath, 'dataset', ...
         'action', 'default_model', ...
         'task', {'vismotion'}, ...
         'space', {'individual'}, ...
         'ignore', {'contrasts', 'transformations', 'dataset'}, ...
         'verbosity', 0, ...
         'skip_validation', true);

  % make sure the file was created where expected
  expectedFilename = fullfile(outputPath, 'derivatives', 'models', ...
                              'model-defaultVismotion_smdl.json');

  % check it has the right content
  content = spm_jsonread(expectedFilename);

  assertEqual(isfield(content.Nodes, 'Transformations'), false);
  assertEqual(isfield(content.Nodes, 'Contrasts'), false);
  assertEqual(numel(content.Nodes), 2);
  assertEqual(numel(content.Edges), 1);

end
