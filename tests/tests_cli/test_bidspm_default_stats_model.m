function test_suite = test_bidspm_default_stats_model %#ok<*STOUT>

  % (C) Copyright 2023 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_createDefaultStatsModel_CLI_ignore()

  outputPath = tmpName();

  opt = setOptions('vislocalizer', '');

  bidspm(opt.dir.input, outputPath, 'dataset', ...
         'action', 'default_model', ...
         'task', {'vismotion'}, ...
         'space', {'individual'}, ...
         'ignore', {'contrasts', 'transformations', 'dataset'}, ...
         'verbosity', 0);

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

function test_createDefaultStatsModel_CLI()

  outputPath = tmpName();

  opt = setOptions('vislocalizer', '');

  bidspm(opt.dir.input, outputPath, 'dataset', ...
         'action', 'default_model', ...
         'task', {'vislocalizer', 'vismotion'}, ...
         'space', {'individual'}, ...
         'verbosity', 0);

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
    assertEqual(content.Nodes, expectedContent.Nodes);
    assertEqual(content.Edges, expectedContent.Edges);
    assertEqual(content.Input, expectedContent.Input);
  end

end

function pth = tmpName()
  pth = tempname();
  mkdir(pth);
end
