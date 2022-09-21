function test_suite = test_convertOnsetTsvToMat %#ok<*STOUT>
  %

  % (C) Copyright 2022 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_convertOnsetTsvToMat_globbing_conditions()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), ...
                     'tsv_files', ...
                     'sub-01_task-FaceRepetitionAfter_events.tsv');
  opt = setOptions('vismotion');

  opt.model.bm = BidsModel('file', opt.model.file);

  opt.model.bm.Input.task = {'FaceRepetitionAfter'};
  opt.model.bm.Nodes{1}.Model.X = {
                                   'trial_type.N*'
                                   'trial_type.F*'
                                   'trans_?'
                                   'rot_?'};

  opt.model.bm.Nodes{1}.Model.HRF.Variables = {
                                               'trial_type.N*'
                                               'trial_type.F*'
                                              };

  % WHEN
  fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile);

  % THEN
  assertEqual(fullfile(getDummyDataDir(), ...
                       'tsv_files', ...
                       'sub-01_task-FaceRepetitionAfter_onsets.mat'), ...
              fullpathOnsetFilename);
  assertEqual(exist(fullpathOnsetFilename, 'file'), 2);

  load(fullpathOnsetFilename);

  assertEqual(names, {'N1', 'N2', 'F1', 'F2'});
  assertEqual(cellfun('size', onsets, 2), [26 26 26 26]);
  assertEqual(cellfun('size', durations, 2), [26 26 26 26]);

  cleanUp(fullpathOnsetFilename);

end

function test_convertOnsetTsvToMat_parametric_modulation()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), ...
                     'tsv_files', ...
                     'sub-01_task-vismotion_events.tsv');
  opt = setOptions('vismotion');

  opt.model.bm = BidsModel('file', opt.model.file);

  trans = struct('Description', 'add dummy param mod', ...
                 'Transformer', 'cpp_spm', ...
                 'Instructions', {{ ...
                                   struct('Name', 'Constant', ...
                                          'Value', 3, ...
                                          'Output', 'pmod_amp'), ...
                                   struct('Name', 'Power', ...
                                          'Input', 'pmod_amp', ...
                                          'Value', 2, ...
                                          'Output', 'pmod_amp_squared')
                                  }});

  opt.model.bm.Nodes{1}.Transformations = trans;

  % WHEN
  fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile);

  load(fullpathOnsetFilename, 'names', 'onsets', 'durations', 'pmod');

  assertEqual(names, {'VisMot', 'VisStat'});
  assertEqual(onsets, {2, 4});
  assertEqual(durations, {2, 2});

  assertEqual(pmod(1).name{1}, 'amp');
  assertEqual(pmod(1).param(1), {3});
  assertEqual(pmod(1).name{2}, 'amp_squared');
  assertEqual(pmod(1).param(2), {9});

  assertEqual(pmod(2).name{1}, 'amp');
  assertEqual(pmod(2).param(1), {3});
  assertEqual(pmod(2).name{2}, 'amp_squared');
  assertEqual(pmod(2).param(2), {9});

  cleanUp(fullpathOnsetFilename);

end

function test_convertOnsetTsvToMat_warning_missing_variable_to_convolve

  if isOctave
    return
  end

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), ...
                     'tsv_files', ...
                     'sub-01_task-vismotion_events.tsv');
  opt = setOptions('vismotion');
  opt.model.file = fullfile(getDummyDataDir(),  'models', ...
                            'model-vismotionWithExtraVariable_smdl.json');
  opt.model.bm = BidsModel('file', opt.model.file);

  opt.verbosity = 1;

  % WHEN
  assertWarning(@() convertOnsetTsvToMat(opt, tsvFile), ...
                'convertOnsetTsvToMat:variableNotFound');

end

function test_convertOnsetTsvToMat_transformers_with_dummy_regressors

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), ...
                     'tsv_files', ...
                     'sub-01_task-vismotion_events.tsv');
  opt = setOptions('vismotion');
  opt.model.file = fullfile(getDummyDataDir(),  'models', ...
                            'model-vismotionWithExtraVariable_smdl.json');
  opt.model.bm = BidsModel('file', opt.model.file);

  opt.glm.useDummyRegressor = true;

  % WHEN
  fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile);

  % THEN
  load(fullpathOnsetFilename);

  assertEqual(names, {'VisMot', 'VisStat', 'dummyRegressor'});

  cleanUp(fullpathOnsetFilename);

end

function test_convertOnsetTsvToMat_basic()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), ...
                     'tsv_files', ...
                     'sub-01_task-vismotion_events.tsv');
  opt = setOptions('vismotion');
  opt.model.bm = BidsModel('file', opt.model.file);

  % WHEN
  fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile);

  % THEN
  assertEqual(fullfile(getDummyDataDir(), ...
                       'tsv_files', ...
                       'sub-01_task-vismotion_onsets.mat'), ...
              fullpathOnsetFilename);
  assertEqual(exist(fullpathOnsetFilename, 'file'), 2);

  load(fullpathOnsetFilename);

  assertEqual(names, {'VisMot', 'VisStat'});
  assertEqual(onsets, {2, 4});
  assertEqual(durations, {2, 2});

  cleanUp(fullpathOnsetFilename);

end

function test_convertOnsetTsvToMat_input_from_non_trial_type_column

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), 'tsv_files', 'sub-01_task-FaceRepetitionBefore_events.tsv');
  opt = setOptions('vismotion');
  opt.model.file = fullfile(getDummyDataDir(),  'models', ...
                            'model-faceRepetitionNoTrialType_smdl.json');
  opt.model.bm = BidsModel('file', opt.model.file);

  % WHEN
  fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile);

  % THEN
  load(fullpathOnsetFilename);

  assertEqual(names, {'famous', 'unfamiliar'});
  assertEqual(numel(onsets{1}), 52);
  assertEqual(durations, {zeros(1, 52), zeros(1, 52)});

  cleanUp(fullpathOnsetFilename);

end

function test_convertOnsetTsvToMat_no_condition_in_design_matrix

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), ...
                     'tsv_files', ...
                     'sub-01_task-vismotion_events.tsv');

  opt = setOptions('vismotion');
  opt.model.file = fullfile(getDummyDataDir(),  'models', ...
                            'model-vismotionNoCondition_smdl.json');
  opt.model.bm = BidsModel('file', opt.model.file);

  opt.verbosity = 1;

  % WHEN
  fullpathOnsetFilename =  convertOnsetTsvToMat(opt, tsvFile);

  load(fullpathOnsetFilename);

  assertEqual(names, {});
  assertEqual(onsets, {});
  assertEqual(durations, {});

end

function test_convertOnsetTsvToMat_dummy_regressor()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), ...
                     'tsv_files', ...
                     'sub-01_task-vismotion_events.tsv');
  opt = setOptions('vismotion');

  opt.model.bm = BidsModel('file', opt.model.file);
  opt.model.bm.Nodes{1}.Model.X{1} = 'trial_type.foo';
  opt.model.bm.Nodes{1}.Model.HRF.Variables{1} = 'trial_type.foo';

  opt.glm.useDummyRegressor = true;

  % WHEN
  fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile);

  % THEN
  load(fullpathOnsetFilename);

  assertEqual(names, {'dummyRegressor', 'VisStat'});
  assertEqual(onsets, {nan, 4});
  assertEqual(durations, {nan, 2});

  cleanUp(fullpathOnsetFilename);

end

function test_convertOnsetTsvToMat_missing_trial_type()

  if isOctave
    return
  end

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), ...
                     'tsv_files', ...
                     'sub-01_task-vismotion_events.tsv');
  opt = setOptions('vismotion');

  opt.model.bm = BidsModel('file', opt.model.file);
  opt.model.bm.Nodes{1}.Model.X{1} = 'trial_type.foo';
  opt.model.bm.Nodes{1}.Model.HRF.Variables{1} = 'trial_type.foo';

  opt.verbosity = 1;

  assertWarning(@() convertOnsetTsvToMat(opt, tsvFile), ...
                'convertOnsetTsvToMat:trialTypeNotFound');

end

function opt = setUp(opt)
  opt.model.bm = BidsModel('file', opt.model.file);
end

function cleanUp(inputFile)
  delete(inputFile);
end
