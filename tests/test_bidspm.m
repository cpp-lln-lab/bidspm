function test_suite = test_bidspm %#ok<*STOUT>

  % (C) Copyright 2023 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_bidsCreateROI_CLI()

  bidspm(pwd, fullfile(pwd, 'tmp'), ...
         'subject', ...
         'action', 'create_roi', ...
         'roi_atlas', 'wang', ...
         'roi_name', {'V1v', 'V1d'}, ...
         'space', {'IXI549Space'});

  cleanUp(fullfile(pwd, 'tmp'));
  cleanUp(fullfile(pwd, 'options'));
  cleanUp(fullfile(pwd, 'error_logs'));

  if ~isOctave()
    bidspm(pwd, fullfile(pwd, 'tmp'), ...
           'subject', ...
           'action', 'create_roi', ...
           'roi_atlas', 'visfatlas', ...
           'roi_name', {'OTS'}, ...
           'space', {'IXI549Space'});

    cleanUp(fullfile(pwd, 'tmp'));
    cleanUp(fullfile(pwd, 'options'));
    cleanUp(fullfile(pwd, 'error_logs'));
  end

  bidspm(pwd, fullfile(pwd, 'tmp'), ...
         'subject', ...
         'action', 'create_roi', ...
         'roi_atlas', 'neuromorphometrics', ...
         'roi_name', {'SCA subcallosal area'}, ...
         'space', {'IXI549Space'});

  cleanUp(fullfile(pwd, 'tmp'));
  cleanUp(fullfile(pwd, 'options'));
  cleanUp(fullfile(pwd, 'error_logs'));

  % requires some deformation field to work

  %   if ~isGithubCi
  %
  %     bidspm(pwd, fullfile(pwd, 'tmp'), ...
  %            'subject', ...
  %            'action', 'create_roi', ...
  %            'roi_atlas', 'neuromorphometrics', ...
  %            'roi_name', {'SCA subcallosal area'}, ...
  %            'space', {'individual'});
  %
  %   cleanUp(fullfile(pwd, 'tmp'));
  %   cleanUp(fullfile(pwd, 'options'));
  %   cleanUp(fullfile(pwd, 'error_logs'));
  %
  %   end

end

function test_boilerplate_stats_only()

  % GIVEN

  opt = setOptions('MoAE');

  cleanUp(fullfile(opt.dir.derivatives));
  spm_mkdir(opt.dir.preproc);

  bidspm(opt.dir.raw, opt.dir.derivatives, 'subject', ...
         'action', 'stats', ...
         'preproc_dir', opt.dir.preproc, ...
         'model_file',  opt.model.file, ...
         'boilerplate_only', true, ...
         'verbosity', 0, ...
         'fwhm', 6);

  assertEqual(exist(fullfile(opt.dir.derivatives, ...
                             'bidspm-stats', ...
                             'reports', ...
                             'stats_model-auditory_citation.md'), ...
                    'file'), ...
              2);

  cleanUp(fullfile(opt.dir.derivatives));

end

function test_boilerplate_preproc_only()

  % GIVEN

  opt = setOptions('MoAE');

  cleanUp(fullfile(opt.dir.derivatives));
  spm_mkdir(opt.dir.preproc);

  bidspm(opt.dir.raw, opt.dir.derivatives, 'subject', ...
         'action', 'preprocess', ...
         'boilerplate_only', true, ...
         'task', {'auditory'}, ...
         'verbosity', 0, ...
         'fwhm', 6);

  assertEqual(exist(fullfile(opt.dir.derivatives, ...
                             'bidspm-preproc', ...
                             'reports', ...
                             'preprocess_citation.md'), ...
                    'file'), ...
              2);

  cleanUp(fullfile(opt.dir.derivatives));

end

function test_createDefaultStatsModel_CLI_ignore()

  opt = setOptions('vislocalizer', '');

  bidspm(opt.dir.input, pwd, 'dataset', ...
         'action', 'default_model', ...
         'task', {'vismotion'}, ...
         'space', {'individual'}, ...
         'ignore', {'contrasts', 'transformations', 'dataset'}, ...
         'verbosity', 3);

  % make sure the file was created where expected
  expectedFilename = fullfile(pwd, 'derivatives', 'models', ...
                              'model-defaultVismotion_smdl.json');

  % check it has the right content
  content = spm_jsonread(expectedFilename);

  assertEqual(isfield(content.Nodes, 'Transformations'), false);
  assertEqual(isfield(content.Nodes, 'Contrasts'), false);
  assertEqual(numel(content.Nodes), 2);
  assertEqual(numel(content.Edges), 1);

  cleanUp(fullfile(pwd, 'derivatives'));

end

function test_createDefaultStatsModel_CLI()

  opt = setOptions('vislocalizer', '');

  bidspm(opt.dir.input, pwd, 'dataset', ...
         'action', 'default_model', ...
         'task', {'vislocalizer', 'vismotion'}, ...
         'space', {'individual'}, ...
         'verbosity', 0);

  % make sure the file was created where expected
  expectedFilename = fullfile(pwd, 'derivatives', 'models', ...
                              'model-defaultVislocalizerVismotion_smdl.json');
  assertEqual(exist(expectedFilename, 'file'), 2);

  % check it has the right content
  content = spm_jsonread(expectedFilename);

  expectedContent = spm_jsonread(fullfile(getDummyDataDir(), 'models', 'model-default_smdl.json'));
  expectedContent.Input.task = {'vislocalizer'; 'vismotion'};
  expectedContent.Input.space = {'individual'};

  if ~isGithubCi
    assertEqual(content.Nodes, expectedContent.Nodes);
    assertEqual(content.Edges, expectedContent.Edges);
    assertEqual(content.Input, expectedContent.Input);
  end

  cleanUp(fullfile(pwd, 'derivatives'));

end
