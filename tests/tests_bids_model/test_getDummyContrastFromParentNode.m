function test_suite = test_getDummyContrastFromParentNode %#ok<*STOUT>
  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getContrastsFromParentNode_basic()
  %
  % run --> session --> subject --> dataset

  model = setUp();

  model = model.get_edges_from_nodes();

  % run node have no previous node
  node = model.Nodes{1};
  dummyContrastsList = getDummyContrastFromParentNode(model, node);
  assert(isempty(dummyContrastsList));

  % session node
  node = model.Nodes{2};
  dummyContrastsList = getDummyContrastFromParentNode(model, node);
  assertEqual(dummyContrastsList, {'sign_Stim1F'});

  % subject node
  node = model.Nodes{3};
  dummyContrastsList = getDummyContrastFromParentNode(model, node);
  assertEqual(dummyContrastsList, {'sign_Stim1F'});

  % dataset node
  node = model.Nodes{4};
  dummyContrastsList = getDummyContrastFromParentNode(model, node);
  assertEqual(dummyContrastsList, {'sign_Stim1F'});
end

function test_getContrastsFromParentNode_v_shaped()
  %
  % run --> session
  % run --> subject

  model = setUp();

  model.Edges{1} = struct('Source', 'Run', 'Destination', 'Subject');
  model.Edges{2} = struct('Source', 'Run', 'Destination', 'Session');

  % session node
  node = model.Nodes{2};
  dummyContrastsList = getDummyContrastFromParentNode(model, node);
  assertEqual(dummyContrastsList, {'sign_Stim1F'});

  % subject node
  node = model.Nodes{3};
  dummyContrastsList = getDummyContrastFromParentNode(model, node);
  assertEqual(dummyContrastsList, {'sign_Stim1F'});

end

function test_getContrastsFromParentNode_filter()
  %
  % run --> session --> dataset (only foo)
  % run --> subject (all)
  %

  model = setUp();

  model.Nodes{1}.DummyContrasts.Contrasts{1} = {'sign_Stim1F', 'foo'};

  model.Edges{1} = struct('Source', 'Run', 'Destination', 'Subject');
  model.Edges{2, 1} = struct('Source', 'Run', ...
                             'Destination', 'Session', ...
                             'Filter', struct('contrast', {{'foo'}}));
  model.Edges{3, 1} = struct('Source', 'Session', ...
                             'Destination', 'Dataset');
  % subject node
  node = model.Nodes{3};
  dummyContrastsList = getDummyContrastFromParentNode(model, node);
  assertEqual(dummyContrastsList, {{'sign_Stim1F', 'foo'}});

  % session node
  node = model.Nodes{2};
  dummyContrastsList = getDummyContrastFromParentNode(model, node);
  assertEqual(dummyContrastsList, {'foo'});

  % dataset node
  node = model.Nodes{4};
  dummyContrastsList = getDummyContrastFromParentNode(model, node);
  assertEqual(dummyContrastsList, {'foo'});

end

function model = setUp()
  model = BidsModel('init', true);

  model.Nodes{1}.DummyContrasts.Contrasts{1} = 'sign_Stim1F';

  model.Nodes{2, 1} = model.Nodes{1};
  model.Nodes{end}.Name = 'Session';
  model.Nodes{end}.Level = 'session';
  model.Nodes{end}.Contrasts = [];
  model.Nodes{end}.DummyContrasts = rmfield(model.Nodes{end}.DummyContrasts, ...
                                            'Contrasts');

  model.Nodes{3, 1} = model.Nodes{2};
  model.Nodes{end}.Name = 'Subject';
  model.Nodes{end}.Level = 'subject';

  model.Nodes{4, 1} = model.Nodes{3};
  model.Nodes{end}.Name = 'Dataset';
  model.Nodes{end}.Level = 'dataset';
end
