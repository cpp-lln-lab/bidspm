% (C) Copyright 2020 bidspm developers

function test_suite = test_bidsModel %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_validateConstrasts()

  opt = setOptions('vislocalizer');
  bm = BidsModel('file', opt.model.file);

  bm.validateConstrasts();

  bm.Nodes{1}.Contrasts{1}.ConditionList{1} = 'foo1';
  bm.validateConstrasts();

  bmWithInvalidConstrast = bm;
  bmWithInvalidConstrast.Nodes{1}.Contrasts{1}.ConditionList{1} = 'foo_1';
  assertExceptionThrown(@()bmWithInvalidConstrast.validateConstrasts(), ...
                        'BidsModel:invalidConditionName');

  bmWithInvalidConstrast = bm;
  bmWithInvalidConstrast.Nodes{1}.DummyContrasts.Contrasts{2} = 'bar_2';
  assertExceptionThrown(@()bmWithInvalidConstrast.validateConstrasts(), ...
                        'BidsModel:invalidConditionName');

  bmWithInvalidConstrast.validateConstrasts();

end

function test_getResults()

  opt = setOptions('vislocalizer');
  bm = BidsModel('file', opt.model.file);
  results = bm.getResults();

  assertEqual(numel(results), 4);
  assertEqual(results(1).nodeName, 'run_level');
  assertEqual(results(2).nodeName, 'run_level');
  assertEqual(results(3).nodeName, 'subject_level');
  assertEqual(results(4).nodeName, 'dataset_level');

end

function test_get_root_node_bug_605()

  % https://github.com/cpp-lln-lab/bidspm/issues/605

  opt = setOptions('vislocalizer');

  bm = BidsModel('file', opt.model.file);

  bm.Edges = struct('Source', 'run_level', ...
                    'Destination', 'subject_level');

  [rootNode, rootNodeName] = bm.get_root_node;

  assertEqual(rootNode.Level, 'Run');
  assertEqual(rootNodeName, 'run_level');

end

function test_getModelType()

  opt = setOptions('vislocalizer');
  bm = BidsModel('file', opt.model.file);

  modelType1 = bm.getModelType('Level', 'Subject');
  assertEqual(modelType1, 'glm');

  modelType2 = bm.getModelType('Name', 'run_level');
  assertEqual(modelType2, 'glm');

  modelType3 = bm.getModelType();
  assertEqual(modelType3, 'glm');

end

function test_getBidsDesignMatrix()

  opt = setOptions('vislocalizer');
  bm = BidsModel('file', opt.model.file);

  designMatrix = bm.getBidsDesignMatrix();

  expected = {'trial_type.VisMot'
              'trial_type.VisStat'
              'trial_type.missing_condition'
              'trans_?'
              'rot_?'};

  assertEqual(designMatrix, expected);

  designMatrix = bm.getBidsDesignMatrix('Name', 'run_level');
  assertEqual(designMatrix, expected);

  designMatrix = bm.getBidsDesignMatrix('Name', 'dataset_level');
  expected = 1;
  assertEqual(designMatrix, expected);

end

function test_getBidsTransformers()

  opt = setOptions('balloonanalogrisktask');
  bm = BidsModel('file', opt.model.file);

  transformers = bm.getBidsTransformers();

  expected{1, 1}.Name = 'Factor';
  expected{1}.Inputs = {'trial_type'};
  expected{2, 1}.Name = 'Convolve';
  expected{2}.Model = 'spm';
  expected{2}.Inputs = {' '};

  assertEqual(transformers{1}, expected{1});
  assertEqual(transformers{2}, expected{2});

  transformers = bm.getBidsTransformers('Name', 'dataset_level');

  assert(isempty(transformers));

end

function test_getHighPassFilter()

  opt = setOptions('vislocalizer');
  bm = BidsModel('file', opt.model.file);

  HPF = bm.getHighPassFilter();

  assertEqual(HPF, 125);

end

function test_getVariablesToConvolve_method()

  opt = setOptions('vislocalizer');
  bm = BidsModel('file', opt.model.file);

  variablesToConvolve = bm.getVariablesToConvolve();
  assertEqual(variablesToConvolve, {'trial_type.VisMot'; 'trial_type.VisStat'});

end

function test_getVariablesToConvolve_warning()

  opt = setOptions('vislocalizer');
  bm = BidsModel('file', opt.model.file);

  if bids.internal.is_octave()
    return
  end
  assertWarning(@()bm.getVariablesToConvolve('Name', 'dataset_level'), ...
                'BidsModel:noVariablesToConvolve');

end

function test_getHRFderivatives()

  opt = setOptions('vislocalizer');
  bm = BidsModel('file', opt.model.file);

  bm.Nodes{1}.Model.HRF.Model = ' spm + derivative';

  HRF = bm.getHRFderivatives();

  assertEqual(HRF, [1 0]);

end

function test_getModelMask_method()

  opt = setOptions('vislocalizer');
  bm = BidsModel('file', opt.model.file);
  bm.verbose = false;

  mask = bm.getModelMask('Name', 'subject_level');
  assertEqual(mask, '');

  bm.Nodes{1}.Model.Options.Mask = 'mask.nii';
  mask = bm.getModelMask('Name', 'run_level');
  assertEqual(mask, 'mask.nii');

  if bids.internal.is_octave()
    return
  end
  bm.verbose = true;
  bm.Nodes{1}.Model.Options = rmfield(bm.Nodes{1}.Model.Options, 'Mask');
  assertWarning(@()bm.getModelMask('Name', 'run_level'), ...
                'BidsModel:noMask');

end

function test_getInclusiveMaskThreshold()

  opt = setOptions('vislocalizer');
  bm = BidsModel('file', opt.model.file, 'verbose', false);

  inclusiveMaskThreshold = bm.getInclusiveMaskThreshold('Name', 'run_level');
  assertEqual(inclusiveMaskThreshold, 0);

  inclusiveMaskThreshold = bm.getInclusiveMaskThreshold();
  assertEqual(inclusiveMaskThreshold, 0);

end

function test_getSerialCorrelationCorrection()

  opt = setOptions('vislocalizer');
  bm = BidsModel('file', opt.model.file, 'verbose', false);

  serialCorrelationCorrection = bm.getSerialCorrelationCorrection('Name', 'run_level');
  assertEqual(serialCorrelationCorrection, 'FAST');

  serialCorrelationCorrection = bm.getSerialCorrelationCorrection();
  assertEqual(serialCorrelationCorrection, 'FAST');

end

function test_getInclusiveMaskThreshold_method()

  opt = setOptions('vislocalizer');
  bm = BidsModel('file', opt.model.file, 'verbose', true);

  bm.getInclusiveMaskThreshold('Name', 'subject_level');

  if bids.internal.is_octave()
    return
  end
  assertWarning(@()bm.getInclusiveMaskThreshold('Name', 'subject_level'), ...
                'BidsModel:noInclMaskThresh');

end

function test_getGrpLevelContrast_basic()

  opt = setOptions('vismotion');

  bm = bids.Model('file', opt.model.file);
  [grpLvlCon, iNode] = bm.get_dummy_contrasts('Level', 'dataset');

  DummyContrasts = struct('Test', 't');

  assertEqual(iNode, 3);
  assertEqual(grpLvlCon, DummyContrasts);

  %%
  opt = setOptions('vislocalizer');
  bm = bids.Model('file', opt.model.file);
  [grpLvlCon, iNode] = bm.get_dummy_contrasts('Level', 'dataset');

  DummyContrasts = struct('Test', 't');

  assertEqual(iNode, 3);
  assertEqual(grpLvlCon, DummyContrasts);

end
