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
  opt.pipeline.isBms = false;

  opt = getOptionsFromModel(opt);

  expectedOptions.pipeline.type = 'preproc';
  expectedOptions.pipeline.isBms = false;

  assertEqual(opt, expectedOptions);

end

function test_getOptionsFromModel_no_model()

  opt.pipeline.type = 'stats';
  opt.model.file = '';
  opt.tolerant = true;
  opt.verbosity = 1;
  opt.pipeline.isBms = false;

  assertExceptionThrown(@() getOptionsFromModel(opt), 'getOptionsFromModel:modelFileMissing');

end

function test_getOptionsFromModel_basic()

  opt.pipeline.type = 'stats';
  opt.model.file = modelFile('dummy');
  opt.verbosity = 0;
  opt.tolerant = true;
  opt.pipeline.isBms = false;

  opt = getOptionsFromModel(opt);

  expectedOptions.pipeline.type = 'stats';
  expectedOptions.pipeline.isBms = false;
  expectedOptions.model.file = modelFile('dummy');
  expectedOptions.verbosity = 0;
  expectedOptions.tolerant = true;
  expectedOptions.model.bm = BidsModel('file', modelFile('dummy'), ...
                                       'verbose', expectedOptions.verbosity > 0, ...
                                       'tolerant', expectedOptions.tolerant);

  expectedOptions.taskName = {'dummy'};

  assertEqual(opt.model.bm.content, expectedOptions.model.bm.content);
  assertEqual(opt.pipeline, expectedOptions.pipeline);
  assertEqual(opt.taskName, expectedOptions.taskName);
  assertEqual(opt.verbosity, expectedOptions.verbosity);
  assertEqual(opt.model.file, expectedOptions.model.file);
  assertEqual(opt.model.bm, expectedOptions.model.bm);

end

function test_getOptionsFromModel_task()

  opt.pipeline.type = 'stats';
  opt.taskName = {'foo'};
  opt.model.file = modelFile('dummy');
  opt.verbosity = 0;
  opt.tolerant = true;
  opt.pipeline.isBms = false;

  opt = getOptionsFromModel(opt);

  assertEqual(opt.taskName, {'dummy'});

  %%
  opt.taskName = {'foo'};
  opt.verbosity = 1;
  opt.tolerant = true;

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
  opt.tolerant = true;
  opt.pipeline.isBms = false;

  opt = getOptionsFromModel(opt);

  assertEqual(opt.subjects, {'02', '04'});

  %%
  opt.subjects = '02';
  opt.verbosity = 1;

  assertWarning(@() getOptionsFromModel(opt), 'getOptionsFromModel:modelOverridesOptions');

end

function test_getOptionsFromModel_space()

  opt.pipeline.type = 'stats';
  opt.space = 'MNI';
  opt.taskName = {'vislocalizer'};
  opt.model.file = modelFile('vislocalizer');
  opt.verbosity = 0;
  opt.tolerant = true;
  opt.pipeline.isBms = false;

  opt = getOptionsFromModel(opt);

  assertEqual(opt.space, {'IXI549Space'});

  %%
  opt.space = 'MNI';
  opt.verbosity = 2;

  assertWarning(@() getOptionsFromModel(opt), 'getOptionsFromModel:modelOverridesOptions');

end

function test_getOptionsFromModel_query()

  opt.pipeline.type = 'stats';
  opt.model.file = modelFile('bug385');
  opt.query.acq = 'foo';
  opt.verbosity = 0;
  opt.tolerant = true;
  opt.pipeline.isBms = false;

  opt = getOptionsFromModel(opt);

  assertEqual(opt.query.acq, {''});

  %%
  opt.query.acq = 'foo';
  opt.verbosity = 1;

  assertWarning(@() getOptionsFromModel(opt), 'getOptionsFromModel:modelOverridesOptions');

end

function value = modelFile(task)
  value = fullfile(getTestDataDir(),  'models', ['model-' task '_smdl.json']);
end
