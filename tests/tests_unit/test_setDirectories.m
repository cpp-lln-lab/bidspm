% (C) Copyright 2021 bidspm developers

function test_suite = test_setDirectories %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setDirectories_preproc()

  %% preprocess
  opt.dir.preproc = pwd;
  opt.taskName = 'testTask';
  opt.pipeline.type = 'preproc';

  %
  opt = checkOptions(opt);

  %
  expected = defaultOptions();

  expected.dir.derivatives = spm_file(fullfile(pwd, '..', 'derivatives'), 'cpath');
  expected.dir.preproc = fullfile(expected.dir.derivatives, 'bidspm-preproc');
  expected.dir.input = fullfile(expected.dir.derivatives, 'bidspm-preproc');
  expected.dir.output = fullfile(expected.dir.derivatives, 'bidspm-preproc');
  expected.dir.jobs = fullfile(expected.dir.output, 'jobs', opt.taskName{1});
  expected.dir.roi = fullfile(expected.dir.derivatives, 'bidspm-roi');
  expected.dir.stats = '';
  expected.dir.raw = '';

  assertEqual(opt.dir, expected.dir);

end

function test_setDirectories_stats()

  opt.pipeline.type = 'stats';
  opt.dir.raw = fullfile(pwd, 'raw');
  opt.dir.preproc = fullfile(pwd, 'derivatives', 'bidspm-preproc');
  opt.model.file = fullfile(getTestDataDir(),  'models', ['model-dummy_smdl.json']);
  opt = checkOptions(opt);

  %
  expected = defaultOptions();

  expected.dir.raw = fullfile(pwd, 'raw');
  expected.dir.derivatives = fullfile(pwd, 'derivatives');
  expected.dir.preproc = fullfile(expected.dir.derivatives, 'bidspm-preproc');
  expected.dir.stats = fullfile(expected.dir.derivatives, 'bidspm-stats');
  expected.dir.input = expected.dir.preproc;
  expected.dir.output = expected.dir.stats;
  expected.dir.jobs = fullfile(expected.dir.output, 'jobs');
  expected.dir.roi = fullfile(expected.dir.derivatives, 'bidspm-roi');

end

function test_setDirectories_inputs_outputs()

  opt.dir.raw = fullfile(fileparts(mfilename('fullpath')), 'inputs', 'raw');
  opt.dir.preproc = fullfile(opt.dir.raw, '..', '..', 'outputs', 'derivatives');
  opt.pipeline.type = 'preproc';
  opt = checkOptions(opt);

  %
  expected = defaultOptions();

  baseDir = fullfile(fileparts(mfilename('fullpath')));
  expected.dir.raw = fullfile(baseDir, 'inputs', 'raw');
  expected.dir.derivatives = fullfile(baseDir, 'outputs', 'derivatives');
  expected.dir.preproc = fullfile(expected.dir.derivatives, 'bidspm-preproc');
  expected.dir.input = expected.dir.raw;
  expected.dir.output = expected.dir.preproc;
  expected.dir.jobs = fullfile(expected.dir.output, 'jobs');
  expected.dir.roi = fullfile(expected.dir.derivatives, 'bidspm-roi');

  assertEqual(opt.dir, expected.dir);

end

function test_setDirectories_copy_raw_to_preproc_named()

  %%
  opt.dir.raw = pwd;
  opt.pipeline.name = 'preproc';
  opt.pipeline.type = 'preproc';

  %
  opt = checkOptions(opt);

  %
  expected = defaultOptions();

  expected.dir.raw = pwd;
  expected.dir.input = expected.dir.raw;
  expected.dir.derivatives = spm_file(fullfile(expected.dir.raw, '..', 'derivatives'), 'cpath');
  expected.dir.preproc = fullfile(expected.dir.derivatives, 'preproc');
  expected.dir.output = expected.dir.preproc;
  expected.dir.jobs = fullfile(expected.dir.output, 'jobs');
  expected.dir.roi = fullfile(expected.dir.derivatives, 'bidspm-roi');

  assertEqual(opt.dir, expected.dir);

end

function test_setDirectories_raw_derivatives()

  opt.dir.raw = fullfile(fileparts(mfilename('fullpath')), 'inputs', 'raw');
  opt.dir.derivatives = fullfile(opt.dir.raw, '..', '..', 'outputs', 'derivatives');
  opt.pipeline.type = 'preproc';
  opt = checkOptions(opt);

  %
  expected = defaultOptions();

  expected.dir.raw = fullfile(fileparts(mfilename('fullpath')), 'inputs', 'raw');
  expected.dir.input = expected.dir.raw;
  expected.dir.derivatives = fullfile(fileparts(mfilename('fullpath')), 'outputs', 'derivatives');
  expected.dir.preproc = fullfile(expected.dir.derivatives, 'bidspm-preproc');
  expected.dir.output = expected.dir.preproc;
  expected.dir.jobs = fullfile(expected.dir.output, 'jobs');
  expected.dir.roi = fullfile(expected.dir.derivatives, 'bidspm-roi');
  expected.dir.stats = '';

  assertEqual(opt.dir, expected.dir);

end

function test_setDirectories_input_output()

  %% user specified
  opt.dir.input = pwd;
  opt.dir.output = fullfile(pwd, 'output');
  opt.pipeline.type = 'preproc';

  %
  opt = checkOptions(opt);

  %
  expected = defaultOptions();

  expected.dir.raw = '';
  expected.dir.preproc = '';
  expected.dir.derivatives = '';
  expected.dir.stats = '';
  expected.dir.input = pwd;
  expected.dir.output = fullfile(pwd, 'output');
  expected.dir.jobs = fullfile(opt.dir.output, 'jobs');

  expected.dir = rmfield(expected.dir, 'roi');

  assertEqual(opt.dir, expected.dir);

end

function test_setDirectories_copy_raw_to_preproc()

  opt.dir.raw = pwd;
  opt.pipeline.type = 'preproc';

  %
  opt = checkOptions(opt);

  %
  expected = defaultOptions();

  expected.dir.raw =  pwd;
  expected.dir.input = expected.dir.raw;
  expected.dir.derivatives = spm_file(fullfile(expected.dir.raw, '..', 'derivatives'), 'cpath');
  expected.dir.preproc = fullfile(expected.dir.derivatives, 'bidspm-preproc');
  expected.dir.output = expected.dir.preproc;
  expected.dir.jobs = fullfile(expected.dir.output, 'jobs');
  expected.dir.roi = fullfile(expected.dir.derivatives, 'bidspm-roi');

  assertEqual(opt.dir, expected.dir);

end

function test_setDirectories_copy_fmriprep_to_preproc()

  opt.dir.input = pwd;
  opt.pipeline.type = 'preproc';

  %
  opt = checkOptions(opt);

  %
  expected = defaultOptions();

  expected.dir.input = pwd;
  expected.dir.derivatives = spm_file(fullfile(expected.dir.input, '..', 'derivatives'), 'cpath');
  expected.dir.preproc = fullfile(expected.dir.derivatives, 'bidspm-preproc');
  expected.dir.output = expected.dir.preproc;
  expected.dir.jobs = fullfile(expected.dir.output, 'jobs');
  expected.dir.roi = fullfile(expected.dir.derivatives, 'bidspm-roi');

  assertEqual(opt.dir, expected.dir);

end
