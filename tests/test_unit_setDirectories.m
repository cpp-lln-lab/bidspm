% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_unit_setDirectories %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setDirectories_local()

  opt.dir.input = fullfile( ...
                           fileparts(mfilename('fullpath')), ...
                           'dummyData', 'derivatives', 'fmriprep');

  opt.pipeline.name = 'copy';

  opt = checkOptions(opt);

  %
  expected = defaultOptions();

  baseDir = fullfile(fileparts(mfilename('fullpath')), ...
                     'dummyData', 'derivatives');
  expected.dir.input = fullfile(baseDir, 'fmriprep');
  expected.dir.derivatives = baseDir;
  expected.dir.preproc = fullfile(baseDir, 'copy');
  expected.dir.jobs = fullfile(expected.dir.preproc, 'jobs');

  assertEqual(opt.dir, expected.dir);

end

function test_setDirectories_userSpecified()

  %% user specified
  opt.dir.input = pwd;
  opt.dir.output = fullfile(pwd, 'output');

  %
  opt = checkOptions(opt);

  %
  expected.dir.raw = '';
  expected.dir.preproc = '';
  expected.dir.derivatives = '';
  expected.dir.stats = '';
  expected.dir.input = pwd;
  expected.dir.output = fullfile(pwd, 'output');
  expected.dir.jobs = fullfile(opt.dir.output, 'jobs');

  assertEqual(opt.dir, expected.dir);

end

function test_setDirectories_copyRaw2Preproc()

  opt.dir.raw = pwd;

  %
  opt = checkOptions(opt);

  %
  expected = defaultOptions();

  expected.dir.raw =  pwd;
  expected.dir.input = expected.dir.raw;
  expected.dir.derivatives = spm_file(fullfile(expected.dir.raw, '..', 'derivatives'), 'cpath');
  expected.dir.preproc = fullfile(expected.dir.derivatives, 'cpp_spm');
  expected.dir.jobs = fullfile(expected.dir.preproc, 'jobs');

  assertEqual(opt.dir, expected.dir);

end

function test_setDirectories_copyRaw2Preproc_Named()

  %%
  opt.dir.raw = pwd;
  opt.pipeline.name = 'preproc';

  %
  opt = checkOptions(opt);

  %
  expected = defaultOptions();

  expected.dir.raw =  pwd;
  expected.dir.input = expected.dir.raw;
  expected.dir.derivatives = spm_file(fullfile(expected.dir.raw, '..', 'derivatives'), 'cpath');
  expected.dir.preproc = fullfile(expected.dir.derivatives, 'preproc');
  expected.dir.jobs = fullfile(expected.dir.preproc, 'jobs');

  assertEqual(opt.dir, expected.dir);

end

function test_setDirectories_copyfMRIprep2Preproc()

  opt.dir.input = pwd;

  %
  opt = checkOptions(opt);

  %
  expected = defaultOptions();

  expected.dir.input = pwd;
  expected.dir.derivatives = spm_file(fullfile(expected.dir.input, '..', 'derivatives'), 'cpath');
  expected.dir.preproc = fullfile(expected.dir.derivatives, 'cpp_spm');
  expected.dir.jobs = fullfile(expected.dir.preproc, 'jobs');

  assertEqual(opt.dir, expected.dir);

end

function test_setDirectories_preproc()

  %% preprocess
  opt.dir.preproc = pwd;
  opt.taskName = 'testTask';

  %
  opt = checkOptions(opt);

  %
  expected = defaultOptions();

  expected.dir.derivatives = spm_file(fullfile(pwd, '..', 'derivatives'), 'cpath');
  expected.dir.preproc = fullfile(expected.dir.derivatives, 'cpp_spm');
  expected.dir.jobs = fullfile(expected.dir.preproc, 'jobs', 'testTask');

  assertEqual(opt.dir, expected.dir);

end

function test_setDirectories_stats()

  %% fmri stats
  opt.pipeline.type = 'stats';
  opt.dir.raw = fullfile(pwd, 'raw');
  opt.dir.preproc = fullfile(pwd, 'derivatives', 'cpp_spm-preproc');

  %
  opt = checkOptions(opt);

  %
  expected = defaultOptions();

  expected.dir.raw = fullfile(pwd, 'raw');
  expected.dir.input = expected.dir.raw;
  expected.dir.derivatives = fullfile(pwd, 'derivatives');
  expected.dir.preproc = fullfile(expected.dir.derivatives, 'cpp_spm-preproc');
  expected.dir.stats = fullfile(expected.dir.derivatives, 'cpp_spm-stats');
  expected.dir.jobs = fullfile(expected.dir.stats, 'jobs');

  assertEqual(opt.dir, expected.dir);

end
