function test_suite = test_applyTransformersToEventsTsv %#ok<*STOUT>
  %
  % (C) Copyright 2022 CPP_SPM developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_applyTransformersToEventsTsv_combine_columns()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), 'tsv_files', 'sub-01_task-FaceRepetitionBefore_events.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  transformers{1} = struct('Name', 'Filter', ...
                           'Input', 'face_type', ...
                           'Query', 'face_type==famous', ...
                           'Output', 'Famous');
  transformers{2} = struct('Name', 'Filter', ...
                           'Input', 'repetition_type', ...
                           'Query', 'repetition_type==1', ...
                           'Output', 'FirstRep');
  transformers{3} = struct('Name', 'And', ...
                           'Input', {{'Famous', 'FirstRep'}}, ...
                           'Output', 'tmp');
  transformers{4} = struct('Name', 'Replace', ...
                           'Input', 'tmp', ...
                           'Output', 'trial_type', ...
                           'Replace', struct('tmp_1', 'FamousFirstRep'));
  transformers{5} = struct('Name', 'Delete', ...
                           'Input', {{'tmp', 'Famous', 'FirstRep'}});

  % WHEN
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  % THEN
  assertEqual(fieldnames(tsvContent), fieldnames(newContent));
  assertEqual(unique(newContent.trial_type), {'FamousFirstRep'; 'face'});

  cleanUp();

end

function test_applyTransformersToEventsTsv_touch()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), 'tsv_files', 'sub-01_task-TouchBefore_events.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  transformers{1} = struct('Name', 'Threshold', ...
                           'Input', 'duration', ...
                           'Binarize', true, ...
                           'Output', 'tmp');
  transformers{2} = struct('Name', 'Replace', ...
                           'Input', 'tmp', ...
                           'Output', 'duration', ...
                           'Attribute', 'duration', ...
                           'Replace', struct('duration_1', 1));
  transformers{3} = struct('Name', 'Delete', ...
                           'Input', {{'tmp', 'Famous', 'FirstRep'}});

  % WHEN
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  % THEN
  assertEqual(fieldnames(tsvContent), fieldnames(newContent));

  cleanUp();

end

function test_applyTransformersToEventsTsv_replace_with_output()

  %% GIVEN
  tsvFile = fullfile(getDummyDataDir(), ...
                     'tsv_files', ...
                     'sub-01_task-FaceRepetitionBefore_events.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  transformers(1).Name = 'Replace';
  transformers(1).Input = 'face_type';
  transformers(1).Output = 'tmp';
  transformers(1).Replace = struct('duration_0', 1);
  transformers(1).Attribute = 'duration';

  % WHEN
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  % THEN
  assertEqual(unique(newContent.tmp), 1);

end

function test_applyTransformersToEventsTsv_replace()

  %% GIVEN
  tsvFile = fullfile(getDummyDataDir(), ...
                     'tsv_files', ...
                     'sub-01_task-FaceRepetitionBefore_events.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  transformers(1).Name = 'Replace';
  transformers(1).Input = 'face_type';
  transformers(1).Replace = struct('famous', 'foo');

  % WHEN
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  % THEN
  assertEqual(unique(newContent.face_type), {'foo'; 'unfamiliar'});

  %% GIVEN
  transformers(1).Name = 'Replace';
  transformers(1).Input = 'face_type';
  transformers(1).Replace = struct('duration_0', 1);
  transformers(1).Attribute = 'duration';

  % WHEN
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  % THEN
  assertEqual(unique(newContent.duration), 1);

end

function test_applyTransformersToEventsTsv_add_subtract

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), 'tsv_files', 'sub-01_task-vismotion_events.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  transformers(1).Name = 'Subtract';
  transformers(1).Input = 'onset';
  transformers(1).Value = 3;

  % WHEN
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  % THEN
  assertEqual(newContent.onset, [-1; 1]);

  cleanUp();

end

function test_applyTransformersToEventsTsv_add_subtract_with_output

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), 'tsv_files', 'sub-01_task-vismotion_events.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  transformers(1).Name = 'Subtract';
  transformers(1).Input = 'onset';
  transformers(1).Value = 3;
  transformers(1).Output = 'onset_minus_3';

  transformers(2).Name = 'Add';
  transformers(2).Input = 'onset';
  transformers(2).Value  = 1;
  transformers(2).Output  = 'onset_plus_1';

  % WHEN
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  % THEN
  assert(all(ismember({'onset_plus_1'; 'onset_minus_3'}, fieldnames(newContent))));
  assertEqual(newContent.onset_plus_1, [3; 5]);
  assertEqual(newContent.onset_minus_3, [-1; 1]);

  cleanUp();

end

function test_applyTransformersToEventsTsv_copy()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), 'tsv_files', 'sub-01_task-FaceRepetitionBefore_events.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  transformers = struct('Name', 'Copy', ...
                        'Input', {{'face_type', 'repetition_type'}}, ...
                        'Output', {{'foo', 'bar'}});
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  assert(all(ismember({'foo'; 'bar'}, fieldnames(newContent))));
  assertEqual(newContent.foo, newContent.face_type);
  assertEqual(newContent.bar, newContent.repetition_type);

end

function test_applyTransformersToEventsTsv_constant()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), ...
                     'tsv_files', ...
                     'sub-01_task-vismotionForThreshold_events.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  transformers{1} = struct('Name', 'Constant', ...
                           'Output', 'cst');

  % WHEN
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  assertEqual(newContent.cst, ones(4, 1));

  transformers{1} = struct('Name', 'Constant', ...
                           'Value', 2, ...
                           'Output', 'cst');

  % WHEN
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  assertEqual(newContent.cst, ones(4, 1) * 2);

end

function test_applyTransformersToEventsTsv_filter_by()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), 'tsv_files', 'sub-01_task-FaceRepetitionBefore_events.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  transformers{1} = struct('Name', 'Filter', ...
                           'Input', 'face_type', ...
                           'Query', 'repetition_type==1', ...
                           'By', 'repetition_type', ...
                           'Output', 'face_type_repetition_1');

  % WHEN
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  % THEN
  % TODO

end

function test_applyTransformersToEventsTsv_threshold_output()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), ...
                     'tsv_files', ...
                     'sub-01_task-vismotionForThreshold_events.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  transformers = struct('Name', 'Threshold', ...
                        'Input', 'to_threshold', ...
                        'Output', 'tmp');
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  assertEqual(newContent.tmp, [1; 2; 0; 0]);

end

function test_applyTransformersToEventsTsv_threshold()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), ...
                     'tsv_files', ...
                     'sub-01_task-vismotionForThreshold_events.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  % WHEN
  transformers = struct('Name', 'Threshold', ...
                        'Input', 'to_threshold');
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  % THEN
  assertEqual(newContent.to_threshold, [1; 2; 0; 0]);

  % WHEN
  transformers = struct('Name', 'Threshold', ...
                        'Input', 'to_threshold', ...
                        'Threshold', 1);
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  % THEN
  assertEqual(newContent.to_threshold, [0; 2; 0; 0]);

  % WHEN
  transformers = struct('Name', 'Threshold', ...
                        'Input', 'to_threshold', ...
                        'Binarize', true);
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  % THEN
  assertEqual(newContent.to_threshold, [1; 1; 0; 0]);

  % WHEN
  transformers = struct('Name', 'Threshold', ...
                        'Input', 'to_threshold', ...
                        'Binarize', true, ...
                        'Above', false);
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  % THEN
  assertEqual(newContent.to_threshold, [0; 0; 1; 1]);

  % WHEN
  transformers = struct('Name', 'Threshold', ...
                        'Input', 'to_threshold', ...
                        'Threshold', 1, ...
                        'Binarize', true, ...
                        'Above', true, ...
                        'Signed', false);
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  % THEN
  assertEqual(newContent.to_threshold, [0; 1; 0; 1]);

end

function test_applyTransformersToEventsTsv_delete_select()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), 'tsv_files', 'sub-01_task-FaceRepetitionBefore_events.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  transformers = struct('Name', 'Delete', ...
                        'Input', 'face_type');
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  assert(~(ismember({'face_type'}, fieldnames(newContent))));

  transformers = struct('Name', 'Select', ...
                        'Input', 'face_type');
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  assertEqual({'face_type'}, fieldnames(newContent));

end

function test_applyTransformersToEventsTsv_rename()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), 'tsv_files', 'sub-01_task-FaceRepetitionBefore_events.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  transformers = struct('Name', 'Rename', ...
                        'Input', {{'face_type', 'repetition_type'}}, ...
                        'Output', {{'foo', 'bar'}});
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  assert(all(ismember({'foo'; 'bar'}, fieldnames(newContent))));
  assert(all(~ismember({'face_type'; 'repetition_type'}, fieldnames(newContent))));
  assertEqual(newContent.foo, tsvContent.face_type);
  assertEqual(newContent.bar, tsvContent.repetition_type);

end

function test_applyTransformersToEventsTsv_complex_filter_with_and()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), 'tsv_files', 'sub-01_task-FaceRepetitionBefore_events.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  transformers{1} = struct('Name', 'Filter', ...
                           'Input', 'face_type', ...
                           'Query', 'face_type==famous', ...
                           'Output', 'Famous');
  transformers{2} = struct('Name', 'Filter', ...
                           'Input', 'repetition_type', ...
                           'Query', 'repetition_type==1', ...
                           'Output', 'FirstRep');

  % WHEN
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  % THEN
  assert(all(ismember({'Famous'; 'FirstRep'}, fieldnames(newContent))));
  assertEqual(sum(strcmp(newContent.Famous, 'famous')), 52);
  assertEqual(unique(newContent.Famous), {''; 'famous'});
  assertEqual(nansum(newContent.FirstRep), 52);

  % GIVEN
  transformers{3} = struct('Name', 'And', ...
                           'Input', {{'Famous', 'FirstRep'}}, ...
                           'Output', 'FamousFirstRep');

  % WHEN
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  % THEN
  assertEqual(sum(newContent.FamousFirstRep), 26);

  cleanUp();

end

function test_applyTransformersToEventsTsv_filter()

  % GIVEN
  tsvFile = fullfile(getDummyDataDir(), 'tsv_files', 'sub-01_task-FaceRepetitionAfter_events.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  transformers = struct('Name', 'Filter', ...
                        'Input', 'trial_type', ...
                        'Query', 'trial_type==F1', ...
                        'Output', 'Famous_1');

  % WHEN
  newContent = applyTransformersToEventsTsv(tsvContent, transformers);

  % THEN
  assert(all(ismember({'Famous_1'}, fieldnames(newContent))));
  assertEqual(numel(newContent.Famous_1), 104);
  assertEqual(unique(newContent.Famous_1), {''; 'F1'});

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

function setUp()

end

function cleanUp()

end
