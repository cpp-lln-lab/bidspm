% (C) Copyright 2020 bidspm developers

function test_suite = test_getEventsData %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getEventsData_basic()
  opt = setOptions('vismotion', '01');

  BIDS = bids.layout(opt.dir.input, ...
                     'use_schema', false, ...
                     'index_dependencies', false);

  metadata = bids.query(BIDS, 'metadata', ...
                        'sub', opt.subjects, ...
                        'task', opt.taskName, ...
                        'suffix', 'bold');

  eventsFile = bids.query(BIDS, 'data', ...
                          'sub', opt.subjects, ...
                          'task', opt.taskName, ...
                          'suffix', 'events');

  data = getEventsData(eventsFile{1}, opt.model.file);

  assertEqual(data.conditions, {'VisMot'; 'VisStat'});
end

function test_getEventsData_no_condition_in_matrix()

  opt = setOptions('vismotion', '01');
  opt.model.file = fullfile(getTestDataDir(), 'models', 'model-vismotionNoCondition_smdl.json');

  BIDS = bids.layout(opt.dir.input, ...
                     'use_schema', false, ...
                     'index_dependencies', false);

  metadata = bids.query(BIDS, 'metadata', ...
                        'sub', opt.subjects, ...
                        'task', opt.taskName, ...
                        'suffix', 'bold');

  eventsFile = bids.query(BIDS, 'data', ...
                          'sub', opt.subjects, ...
                          'task', opt.taskName, ...
                          'suffix', 'events');

  data = getEventsData(eventsFile{1}, opt.model.file);

  assertEqual(data, []);
end
