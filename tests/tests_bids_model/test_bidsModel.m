% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_bidsModel %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_returnModelNode()

  content = createEmptyStatsModel();
  content.Nodes{4} = createEmptyNode('dataset');

  [~, iStep] = returnModelNode(content, 'run');
  assertEqual(iStep, 1);

  [~, iStep] = returnModelNode(content, 'dataset');
  assertEqual(iStep, [3; 4]);

  assertExceptionThrown( ...
                        @()returnModelNode(content, 'foo'), ...
                        'returnModelNode:missingModelNode');

  modelFile = fullfile(pwd, 'model.json');
  bids.util.jsonencode(modelFile, content);
  HPF = getHighPassFilter(modelFile);
  designMatrix = getBidsDesignMatrix(modelFile);
  dummyContrastsList = getDummyContrastsList(modelFile);

end

function test_getHighPassFilter()

  opt = setOptions('vislocalizer', '01');

  HPF = getHighPassFilter(opt.model.file);

  assertEqual(HPF, 125);

end

function test_getHRFderivatives()

  opt = setOptions('vislocalizer', '01');

  HRF = getHRFderivatives(opt.model.file);

  assertEqual(HRF, [1 0]);

end

function test_getModelType()

  opt = setOptions('vislocalizer', '01');

  modelType = getModelType(opt.model.file, 'subject');

  assertEqual(modelType, 'glm');

end

function test_getModelMask()

  opt = setOptions('vislocalizer', '01');

  mask = getModelMask(opt.model.file, 'subject');

  assertEqual(mask, '');

end

function test_getInclusiveMaskThreshold()

  opt = setOptions('vislocalizer', '01');

  inclusiveMaskThreshold = getInclusiveMaskThreshold(opt.model.file, 'subject');

  assertEqual(inclusiveMaskThreshold, 0.8);

end

function test_getBidsDesignMatrix()

  opt = setOptions('vislocalizer', '01');

  designMatrix = getBidsDesignMatrix(opt.model.file);

  expected = {'trial_type.VisMot'
              'trial_type.VisStat'
              'trial_type.missing_condition'
              'trans_x'
              'trans_y'
              'trans_z'
              'rot_x'
              'rot_y'
              'rot_z'};

  assertEqual(designMatrix, expected);

end

function test_getContrastsList()

  opt = setOptions('vislocalizer', '01');

  contrastsList = getContrastsList(opt.model.file);

  assertEqual(fieldnames(contrastsList), {'Name'
                                          'ConditionList'
                                          'Weights'
                                          'Test'});

  assertEqual(numel(contrastsList), 2);

end

function test_getDummyContrastsList()

  opt = setOptions('vislocalizer', '01');

  dummyContrastsList = getDummyContrastsList(opt.model.file);

  expected = struct('Test', 't', ...
                    'Contrasts', {{'trial_type.VisMot'
                                   'trial_type.VisStat'}});

  assertEqual(dummyContrastsList.Contrasts, expected.Contrasts);
  assertEqual(dummyContrastsList, expected);

end
