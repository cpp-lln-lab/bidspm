% (C) Copyright 2020 bidspm developers

function test_suite = test_getOptionsFromModel %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getOptionsFromModel_preproc()

  opt.pipeline.type = 'preproc';

  opt = getOptionsFromModel(opt);

  expectedOptions.pipeline.type = 'preproc';

  assertEqual(opt, expectedOptions);

end

function test_getOptionsFromModel_no_model()

  opt.pipeline.type = 'stats';
  opt.model.file = '';

  assertExceptionThrown(@() getOptionsFromModel(opt), 'getOptionsFromModel:modelFileMissing');

end

function test_getOptionsFromModel_basic()

  opt.pipeline.type = 'stats';
  opt.model.file = modelFile('dummy');
  opt.verbosity = 1;

  opt = getOptionsFromModel(opt);

  expectedOptions.pipeline.type = 'stats';
  expectedOptions.model.file = modelFile('dummy');
  expectedOptions.model.bm = BidsModel('file', modelFile('dummy'), ...
                                       'verbose', true, 'tolerant', false);
  expectedOptions.verbosity = 1;
  expectedOptions.taskName = {'dummy'};

  assertEqual(opt, expectedOptions);

end

function test_getOptionsFromModel_task()

  opt.pipeline.type = 'stats';
  opt.taskName = {'foo'};
  opt.model.file = modelFile('dummy');
  opt.verbosity = 0;

  opt = getOptionsFromModel(opt);

  assertEqual(opt.taskName, {'dummy'});

  %%
  opt.taskName = {'foo'};
  opt.verbosity = 2;

  if isOctave
    return
  end

  assertWarning(@() getOptionsFromModel(opt), 'getOptionsFromModel:modelOverridesOptions');

end

function test_getOptionsFromModel_subject()

  opt.pipeline.type = 'stats';
  opt.subjects = '02';
  opt.taskName = {'dummy'};
  opt.model.file = modelFile('dummy');
  opt.model.bm = BidsModel('file', opt.model.file);
  opt.model.bm.Input.subject = {'02', '04'};
  opt.verbosity = 0;

  opt = getOptionsFromModel(opt);

  assertEqual(opt.subjects, {'02', '04'});

  %%
  opt.subjects = '02';
  opt.verbosity = 2;

  if isOctave
    return
  end

  assertWarning(@() getOptionsFromModel(opt), 'getOptionsFromModel:modelOverridesOptions');

end

function test_getOptionsFromModel_space()

  opt.pipeline.type = 'stats';
  opt.space = 'MNI';
  opt.taskName = {'vislocalizer'};
  opt.model.file = modelFile('vislocalizer');
  opt.verbosity = 0;

  opt = getOptionsFromModel(opt);

  assertEqual(opt.space, {'IXI549Space'});

  %%
  opt.space = 'MNI';
  opt.verbosity = 2;

  if isOctave
    return
  end

  assertWarning(@() getOptionsFromModel(opt), 'getOptionsFromModel:modelOverridesOptions');

end

function test_getOptionsFromModel_query()

  opt.pipeline.type = 'stats';
  opt.model.file = modelFile('bug385');
  opt.query.acq = 'foo';
  opt.verbosity = 0;

  opt = getOptionsFromModel(opt);

  assertEqual(opt.query.acq, {''});

  %%
  opt.query.acq = 'foo';
  opt.verbosity = 2;

  if isOctave
    return
  end

  assertWarning(@() getOptionsFromModel(opt), 'getOptionsFromModel:modelOverridesOptions');

end

function value = modelFile(task)
  value = fullfile(getDummyDataDir(),  'models', ['model-' task '_smdl.json']);
end
