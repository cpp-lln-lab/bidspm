% (C) Copyright 2020 bidspm developers

function test_suite = test_createDefaultStatsModel %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_createDefaultStatsModel_basic()

  opt = setOptions('vislocalizer', '');

  BIDS = getLayout(opt);

  opt.dir.derivatives = pwd;
  opt.space = {'IXI549Space'};
  opt.taskName = {'vislocalizer'};

  createDefaultStatsModel(BIDS, opt);

  % make sure the file was created where expected
  expectedFilename = fullfile(pwd, 'models', 'model-defaultVislocalizer_smdl.json');
  assertEqual(exist(expectedFilename, 'file'), 2);

  % check it has the right content
  content = spm_jsonread(expectedFilename);

  expectedContent = spm_jsonread(fullfile(getTestDataDir(), 'models', 'model-default_smdl.json'));

  if ~bids.internal.is_github_ci()
    % silencing because in CI first node design matrix includes a an extra empty
    % regressor
    %
    %
    %   unfoldStruct(content);
    %   unfoldStruct(expectedContent);
    %
    % content.Nodes(1).Model.X{1} = 'trial_type.VisMot' ;
    % content.Nodes(1).Model.X{2} = 'trial_type.VisStat' ;
    % content.Nodes(1).Model.X{3} = 'trans_?' ;
    % content.Nodes(1).Model.X{4} = 'rot_?' ;
    % content.Nodes(1).Model.X{5} = 'non_steady_state_outlier*' ;
    % content.Nodes(1).Model.X{6} = [] ;
    % content.Nodes(1).Model.X{7} = 'motion_outlier*' ;
    %
    % expectedContent.Nodes(1).Model.X{1} = 'trial_type.VisMot';
    % expectedContent.Nodes(1).Model.X{2} = 'trial_type.VisStat';
    % expectedContent.Nodes(1).Model.X{3} = 'trans_?';
    % expectedContent.Nodes(1).Model.X{4} = 'rot_?';
    % expectedContent.Nodes(1).Model.X{5} = 'non_steady_state_outlier*';
    % expectedContent.Nodes(1).Model.X{6} = 'motion_outlier*';

    assertEqual(content.Nodes, expectedContent.Nodes);
    assertEqual(content.Edges, expectedContent.Edges);
    assertEqual(content.Input, expectedContent.Input);
  end

  cleanUp(fullfile(pwd, 'models'));

end

function test_createDefaultStatsModel_ignore()

  opt = setOptions('vislocalizer', '');

  BIDS = getLayout(opt);

  opt.dir.derivatives = pwd;
  opt.space = {'IXI549Space'};
  opt.taskName = {'vislocalizer'};

  opt = createDefaultStatsModel(BIDS, opt, ...
                                {'contrasts', 'transformations', 'dataset'});

  content = spm_jsonread(opt.model.file);

  assertEqual(isfield(content.Nodes, 'Transformations'), false);
  assertEqual(isfield(content.Nodes, 'Contrasts'), false);
  assertEqual(numel(content.Nodes), 2);
  assertEqual(numel(content.Edges), 1);

  cleanUp(fullfile(pwd, 'models'));

end
