function test_suite = test_convertOnsetTsvToMat %#ok<*STOUT>
  %
  % (C) Copyright 2022 CPP_SPM developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_convertOnsetTsvToMat_dummy_regressor()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), 'sub-01_task-vismotion_events.tsv');
  opt = setOptions('vismotion');
  opt.model.file = fullfile(getDummyDataDir(), 'models', 'model-vismotionMVPA_smdl.json');
  opt.glm.useDummyRegressor = true;
  
  
  % WHEN
  fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile);

  % THEN
  assertEqual(fullfile(getDummyDataDir(), 'sub-01_task-vismotion_onsets.mat'), ...
              fullpathOnsetFilename);
  assertEqual(exist(fullpathOnsetFilename, 'file'), 2)
  
  load(fullpathOnsetFilename);
  
  assertEqual(names, {'dummyRegressor'});
  assertEqual(onsets, {[]});
  assertEqual(durations, {[]});

  cleanUp(fullpathOnsetFilename);

end

function test_convertOnsetTsvToMat_missing_trial_type()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), 'sub-01_task-vismotion_events.tsv');
  opt = setOptions('vismotion');
  opt.model.file = fullfile(getDummyDataDir(), 'models', 'model-vismotionMVPA_smdl.json');
  opt.verbosity = 1;
  opt.glm.useDummyRegressor = false;

  assertWarning(@() convertOnsetTsvToMat(opt, tsvFile), ...
    'convertOnsetTsvToMat:emptyTrialType')

end

function test_convertOnsetTsvToMat_no_trial_type_column()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), 'sub-01_task-vismotion_desc-noTrialType_events.tsv');
  opt = setOptions('vismotion');


  assertExceptionThrown(@() convertOnsetTsvToMat(opt, tsvFile), ...
    'convertOnsetTsvToMat:noTrialType')

end

function test_convertOnsetTsvToMat_basic()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), 'sub-01_task-vismotion_events.tsv');
  opt = setOptions('vismotion');

  % WHEN
  fullpathOnsetFilename = convertOnsetTsvToMat(opt, tsvFile);
  
  % THEN
  assertEqual(fullfile(getDummyDataDir(), 'sub-01_task-vismotion_onsets.mat'), ...
              fullpathOnsetFilename);
  assertEqual(exist(fullpathOnsetFilename, 'file'), 2)
  
  load(fullpathOnsetFilename);
  
  assertEqual(names, {'VisMot', 'VisStat'});
  assertEqual(onsets, {2, 4});
  assertEqual(durations, {2, 2});

  cleanUp(fullpathOnsetFilename);

end

function setUp()

end

function cleanUp(inputFile)
 delete(inputFile)
end
