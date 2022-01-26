function test_suite = test_applyTransformersToEventsTsv %#ok<*STOUT>
  %
  % (C) Copyright 2022 CPP_SPM developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_applyTransformersToEventsTsv_no_transformation()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), 'sub-01_task-vismotion_events.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  opt = setOptions('vislocalizer');
  transformers = getBidsTransformers(opt.model.file);

  % WHEN
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  % THEN
  assertEqual(newContent, struct([]));

  cleanUp();

end

function test_applyTransformersToEventsTsv_basic

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), 'sub-01_task-vismotion_events.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  opt.model.file = fullfile(getDummyDataDir(),  'models', ...
                            'model-vismotionWithTransformation_smdl.json');
  transformers = getBidsTransformers(opt.model.file);

  % WHEN
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  % THEN
  assertEqual({'VisMot'; 'VisStat'}, fieldnames(newContent));
  assertEqual(newContent.VisMot, struct('onset', -1, 'duration', 2));
  assertEqual(newContent.VisStat, struct('onset', 5, 'duration', 2));

  cleanUp();

end

function setUp()

end

function cleanUp()

end
