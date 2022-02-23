% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_bidsModel %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_returnModelNode_errors()

  content = createEmptyStatsModel();

  assertExceptionThrown(@()returnModelNode(content, 'foo'), ...
                        'returnModelNode:wrongNodeType');

  content = createEmptyStatsModel();
  content.Nodes{3}  = [];
  assertExceptionThrown(@()returnModelNode(content, 'missingModelNode'), ...
                        'returnModelNode:wrongNodeType');

end

function test_getBidsTransformers_basic()

  opt = setOptions('balloonanalogrisktask');

  transformers = getBidsTransformers(opt.model.file);

  expected{1, 1}.Name = 'Factor';
  expected{1}.Inputs = {'trial_type'};
  expected{2, 1}.Name = 'Convolve';
  expected{2}.Model = 'spm';
  expected{2}.Inputs = {' '};

  assertEqual(transformers{1}, expected{1});
  assertEqual(transformers{2}, expected{2});

end

function test_getBidsModelInputs()

  opt = setOptions('vislocalizer');

  input = getBidsModelInput(opt.model.file);

  assertEqual(input.task, 'vislocalizer');

end

function test_getVariablesToConvolve()

  opt = setOptions('vislocalizer');

  variablesToConvolve = getVariablesToConvolve(opt.model.file);

  assertEqual(variablesToConvolve, {'trial_type.VisMot'; 'trial_type.VisStat'});

end

function test_returnModelNode_struct()

  content.Nodes = struct('Level', 'Run');
  content.Nodes(2).Level = 'Subject';

  [~, iStep] = returnModelNode(content, 'run');
  assertEqual(iStep, 1);

  [~, iStep] = returnModelNode(content, 'Subject');
  assertEqual(iStep, 2);

end

function test_getVariablesToConvolve_warning()

  opt = setOptions('vislocalizer');

  assertWarning(@()getVariablesToConvolve(opt.model.file, 'dataset'), ...
                'getVariablesToConvolve:noVariablesToConvolve');

end

function test_returnModelNode()

  content = createEmptyStatsModel();
  content.Nodes{4} = createEmptyNode('dataset');

  [~, iStep] = returnModelNode(content, 'run');
  assertEqual(iStep, 1);

  [~, iStep] = returnModelNode(content, 'dataset');
  assertEqual(iStep, [3; 4]);

  modelFile = fullfile(pwd, 'model.json');
  bids.util.jsonencode(modelFile, content);
  HPF = getHighPassFilter(modelFile);
  designMatrix = getBidsDesignMatrix(modelFile);
  dummyContrastsList = getDummyContrastsList(modelFile);

end

function test_getHighPassFilter()

  opt = setOptions('vislocalizer');

  HPF = getHighPassFilter(opt.model.file);

  assertEqual(HPF, 125);

end

function test_getHRFderivatives()

  opt = setOptions('vislocalizer');

  HRF = getHRFderivatives(opt.model.file);

  assertEqual(HRF, [1 0]);

end

function test_getModelType()

  opt = setOptions('vislocalizer');

  modelType = getModelType(opt.model.file, 'subject');

  assertEqual(modelType, 'glm');

end

function test_getModelMask()

  opt = setOptions('vislocalizer');

  mask = getModelMask(opt.model.file, 'subject');

  assertEqual(mask, '');

end

function test_getInclusiveMaskThreshold()

  opt = setOptions('vislocalizer');

  inclusiveMaskThreshold = getInclusiveMaskThreshold(opt.model.file, 'subject');

  assertEqual(inclusiveMaskThreshold, 0.8);

end

function test_getBidsDesignMatrix()

  opt = setOptions('vislocalizer');

  designMatrix = getBidsDesignMatrix(opt.model.file);

  expected = {'trial_type.VisMot'
              'trial_type.VisStat'
              'trial_type.missing_condition'
              'trans_?'
              'rot_?'};

  assertEqual(designMatrix, expected);

end

function test_getContrastsList()

  opt = setOptions('vislocalizer');

  contrastsList = getContrastsList(opt.model.file);

  assertEqual(fieldnames(contrastsList), {'Name'
                                          'ConditionList'
                                          'Weights'
                                          'Test'});

  assertEqual(numel(contrastsList), 2);

end

function test_getDummyContrastsList()

  opt = setOptions('vislocalizer');

  dummyContrastsList = getDummyContrastsList(opt.model.file);

  expected = struct('Test', 't', ...
                    'Contrasts', {{'trial_type.VisMot'
                                   'trial_type.VisStat'}});

  assertEqual(dummyContrastsList.Contrasts, expected.Contrasts);
  assertEqual(dummyContrastsList, expected);

end
