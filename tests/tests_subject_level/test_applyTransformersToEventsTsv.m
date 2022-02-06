function test_suite = test_applyTransformersToEventsTsv %#ok<*STOUT>
  %
  % (C) Copyright 2022 CPP_SPM developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_applyTransformersToEventsTsv_filter()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), 'tsv_files', 'sub-01_task-FaceRepetitionAfter_events.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  % Filter(Input, Query, By=None, Output=None):

  transformers = struct('Name', 'Filter', ...
                        'Input', 'trial_type', ...
                        'Query', 'trial_type==F1', ...
                        'Output', 'Famous_1');

  % WHEN
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  % TH
  assertEqual(fieldnames(newContent), {'Famous_1'});

  cleanUp();

end

function test_applyTransformersToEventsTsv_several_inputs_outputs()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), 'tsv_files', 'sub-01_task-vismotion_events.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  transformers = struct('Name', 'Subtract', ...
                        'Input', {{'trial_type.VisMot', 'trial_type.VisStat'}}, ...
                        'Value', 3, ...
                        'Output', {{'VisMot', 'VisStat'}});

  % WHEN
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  % TH
  assertEqual(fieldnames(newContent), {'VisMot'; 'VisStat'});

  cleanUp();

end

function test_applyTransformersToEventsTsv_no_transformation()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), 'tsv_files', 'sub-01_task-vismotion_events.tsv');
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
  tsvFile = fullfile(getDummyDataDir(), 'tsv_files', 'sub-01_task-vismotion_events.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  opt.model.file = fullfile(getDummyDataDir(),  'models', ...
                            'model-vismotionWithTransformation_smdl.json');
  transformers = getBidsTransformers(opt.model.file);

  % WHEN
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  % THEN
  assertEqual(fieldnames(newContent), {'VisMot'; 'VisStat'});
  assertEqual(newContent.VisMot, struct('onset', -1, 'duration', 2));
  assertEqual(newContent.VisStat, struct('onset', 5, 'duration', 2));

  cleanUp();

end

function setUp()

end

function cleanUp()

end
