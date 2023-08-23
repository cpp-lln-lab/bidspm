function test_suite = test_convertOnsetTsvToMat %#ok<*STOUT>
  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_convertOnsetTsvToMat_exclude_late_events()

  % GIVEN
  opt = setOptions('vismotion');
  [opt, tmpDir] = setUp(opt);
  tsvFile = fullfile(tmpDir, 'sub-01_task-vismotion_events.tsv');

  % WHEN
  runDuration = 3;
  fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile, runDuration);

  % THEN
  assertEqual(fullfile(tmpDir, 'sub-01_task-vismotion_onsets.mat'), ...
              fullpathOnsetFilename);
  assertEqual(exist(fullpathOnsetFilename, 'file'), 2);

  load(fullpathOnsetFilename, 'names', 'onsets', 'durations');

  assertEqual(names, {'VisMot'});
  assertEqual(onsets, {2});
  assertEqual(durations, {2});

end

function test_convertOnsetTsvToMat_parametric_modulation()

  % GIVEN
  opt = setOptions('vismotion');
  opt.model.file = fullfile(fileparts(opt.model.file),  ...
                            'model-vismotion_desc-parametric_smdl.json');
  [opt, tmpDir] = setUp(opt);
  tsvFile = fullfile(tmpDir, 'sub-01_task-vismotion_events.tsv');

  % WHEN
  fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile);

  load(fullpathOnsetFilename, 'names', 'onsets', 'durations', 'pmod');

  assertEqual(names, {'VisMot', 'VisStat'});
  assertEqual(onsets, {2, 4});
  assertEqual(durations, {2, 2});

  assertEqual(numel(pmod), 2);

  assertEqual(numel(pmod(1).name), 2);

  assertEqual(pmod(1).name{1}, 'amp_1_pmod');
  assertEqual(pmod(1).param(1), {3});
  assertEqual(pmod(1).poly(1), {1});
  assertEqual(pmod(1).name{2}, 'amp_2_pmod^2');
  assertEqual(pmod(1).param(2), {2});
  assertEqual(pmod(1).poly(2), {2});

  assertEqual(numel(pmod(2).name), 1);

  assertEqual(pmod(2).name{1}, 'amp_1_pmod');
  assertEqual(pmod(2).param(1), {3});
  assertEqual(pmod(2).poly(1), {1});

  clear names onsets durations pmod;

  %%
  bm = opt.model.bm;
  bm.Nodes{1}.Model.Software.SPM.ParametricModulations(2) = [];
  bm.write(fullfile(tmpDir, 'tmp.json'));
  opt.model.file = fullfile(tmpDir, 'tmp.json');
  opt.model.bm = BidsModel('file', opt.model.file);

  fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile);

  load(fullpathOnsetFilename, 'names', 'onsets', 'durations', 'pmod');

  assertEqual(pmod(1).name{1}, 'amp_1_pmod');
  assertEqual(pmod(1).param(1), {3});
  assertEqual(pmod(1).poly(1), {1});

end

function test_convertOnsetTsvToMat_globbing_conditions()

  % GIVEN
  opt = setOptions('vismotion');
  [opt, tmpDir] = setUp(opt);
  tsvFile = fullfile(tmpDir, 'sub-01_task-FaceRepetitionAfter_events.tsv');

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
  assertEqual(fullfile(tmpDir, 'sub-01_task-FaceRepetitionAfter_onsets.mat'), ...
              fullpathOnsetFilename);
  assertEqual(exist(fullpathOnsetFilename, 'file'), 2);

  load(fullpathOnsetFilename, 'names', 'onsets', 'durations');

  assertEqual(names, {'N1', 'N2', 'F1', 'F2'});
  assertEqual(cellfun('size', onsets, 2), [26 26 26 26]);
  assertEqual(cellfun('size', durations, 2), [26 26 26 26]);

end

function test_convertOnsetTsvToMat_warning_missing_variable_to_convolve

  opt = setOptions('vismotion');
  opt.model.file = fullfile(getTestDataDir(),  'models', ...
                            'model-vismotionWithExtraVariable_smdl.json');
  [opt, tmpDir] = setUp(opt);
  tsvFile = fullfile(tmpDir, 'sub-01_task-vismotion_events.tsv');

  opt.verbosity = 1;

  if bids.internal.is_octave()
    moxunit_throw_test_skipped_exception('Octave:mixed-string-concat warning thrown');
  end
  assertWarning(@() convertOnsetTsvToMat(opt, tsvFile), ...
                'convertOnsetTsvToMat:variableNotFound');

end

function test_convertOnsetTsvToMat_transformers_with_dummy_regressors

  % GIVEN
  opt = setOptions('vismotion');
  opt.model.file = fullfile(getTestDataDir(),  'models', ...
                            'model-vismotionWithExtraVariable_smdl.json');
  [opt, tmpDir] = setUp(opt);
  tsvFile = fullfile(tmpDir, 'sub-01_task-vismotion_events.tsv');

  opt.glm.useDummyRegressor = true;

  % WHEN
  fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile);

  % THEN
  load(fullpathOnsetFilename, 'names');

  assertEqual(names, {'VisMot', 'VisStat', 'dummyRegressor'});

end

function test_convertOnsetTsvToMat_basic()

  % GIVEN
  opt = setOptions('vismotion');
  [opt, tmpDir] = setUp(opt);
  tsvFile = fullfile(tmpDir, 'sub-01_task-vismotion_events.tsv');

  % WHEN
  fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile);

  % THEN
  assertEqual(fullfile(tmpDir, 'sub-01_task-vismotion_onsets.mat'), ...
              fullpathOnsetFilename);
  assertEqual(exist(fullpathOnsetFilename, 'file'), 2);

  load(fullpathOnsetFilename, 'names', 'onsets', 'durations');

  assertEqual(names, {'VisMot', 'VisStat'});
  assertEqual(onsets, {2, 4});
  assertEqual(durations, {2, 2});

end

function test_convertOnsetTsvToMat_input_from_non_trial_type_column

  % GIVEN
  opt = setOptions('vismotion');
  opt.model.file = fullfile(getTestDataDir(),  'models', ...
                            'model-faceRepetitionNoTrialType_smdl.json');
  [opt, tmpDir] = setUp(opt);
  tsvFile = fullfile(tmpDir, 'sub-01_task-FaceRepetitionBefore_events.tsv');

  % WHEN
  fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile);

  % THEN
  load(fullpathOnsetFilename, 'names', 'onsets', 'durations');

  assertEqual(names, {'famous', 'unfamiliar'});
  assertEqual(numel(onsets{1}), 52);
  assertEqual(durations, {zeros(1, 52), zeros(1, 52)});

end

function test_convertOnsetTsvToMat_no_condition_in_design_matrix

  % GIVEN
  opt = setOptions('vismotion');
  opt.model.file = fullfile(getTestDataDir(),  'models', ...
                            'model-vismotionNoCondition_smdl.json');
  [opt, tmpDir] = setUp(opt);
  tsvFile = fullfile(tmpDir, 'sub-01_task-vismotion_events.tsv');

  opt.verbosity = 1;

  % WHEN
  fullpathOnsetFilename =  convertOnsetTsvToMat(opt, tsvFile);

  load(fullpathOnsetFilename, 'names', 'onsets', 'durations');

  assertEqual(names, {});
  assertEqual(onsets, {});
  assertEqual(durations, {});

end

function test_convertOnsetTsvToMat_dummy_regressor()

  % GIVEN
  opt = setOptions('vismotion');
  [opt, tmpDir] = setUp(opt);
  tsvFile = fullfile(tmpDir, 'sub-01_task-vismotion_events.tsv');

  opt.model.bm.Nodes{1}.Model.X{1} = 'trial_type.foo';
  opt.model.bm.Nodes{1}.Model.HRF.Variables{1} = 'trial_type.foo';

  opt.glm.useDummyRegressor = true;

  % WHEN
  fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile);

  % THEN
  load(fullpathOnsetFilename, 'names', 'onsets', 'durations');

  assertEqual(names, {'dummyRegressor', 'VisStat'});
  assertEqual(onsets, {nan, 4});
  assertEqual(durations, {nan, 2});

end

function test_convertOnsetTsvToMat_missing_trial_type()

  % GIVEN
  opt = setOptions('vismotion');
  [opt, tmpDir] = setUp(opt);
  tsvFile = fullfile(tmpDir, 'sub-01_task-vismotion_events.tsv');

  opt.model.bm.Nodes{1}.Model.X{1} = 'trial_type.foo';
  opt.model.bm.Nodes{1}.Model.HRF.Variables{1} = 'trial_type.foo';

  opt.verbosity = 1;

  if bids.internal.is_octave()
    moxunit_throw_test_skipped_exception('Octave:mixed-string-concat warning thrown');
  end

  assertWarning(@() convertOnsetTsvToMat(opt, tsvFile), ...
                'convertOnsetTsvToMat:trialTypeNotFound');

end

function [opt, tmpDir] = setUp(opt)
  opt.model.bm = BidsModel('file', opt.model.file);
  tmpDir = tempName();
  copyfile(fullfile(getTestDataDir(), 'tsv_files'), tmpDir);
end
