function test_suite = test_bidsQA %#ok<*STOUT>

  % (C) Copyright 2024 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsQA_raw()

  %   markTestAs('slow');
  %
  %     opt = setOptions('vislocalizer');
  %
  %      expectedOutput = fullfile(opt.dir.output, ...
  %         'reports', ...
  %         'bidspm-raw_split_by-task.png');
  %
  %     if exist(expectedOutput, 'file')
  %         delete(expectedOutput)
  %     end
  %
  %     bidsQA(opt)
  %
  %     assertEqual(exist(expectedOutput, 'file'), 2)

end

function test_bidsQA_mriqc()

  %   markTestAs('slow');
  %
  % if ispc()
  % moxunit_throw_test_skipped_exception('requires datalad setup');
  % end
  %
  %   ds000114mriqc = spm_file(fullfile(getTestDir(), ...
  %                                     '..', 'demos', 'openneuro', ...
  %                                     'inputs', 'ds000114-mriqc'), 'cpath');
  %
  %   opt.dir.input = ds000114mriqc;
  %
  %   bidsQA(opt);

end

function test_bidsQA_bidspm()

  markTestAs('slow');

  if ispc()
    moxunit_throw_test_skipped_exception('requires datalad setup');
  end

  opt = setOptions('vislocalizer');

  opt.dir.input = opt.dir.preproc;

  opt.dir.output = '';
  opt.dir.derivatives = tempName();

  opt = checkOptions(opt);

  threshold = 0.0001;
  metric = 'rot_x';

  filename = bidsQA(opt, 'metric', metric, 'threshold', threshold);

  assertEqual(exist(filename, 'file'), 2);

end

function test_bidsQA_fmriprep()

  markTestAs('slow');

  ds000114fmriprep = spm_file(fullfile(getTestDir(), ...
                                       '..', 'demos', 'openneuro', ...
                                       'inputs', 'ds000114-fmriprep'), 'cpath');

  opt.dir.input = ds000114fmriprep;
  opt.dir.preproc = ds000114fmriprep;
  opt.dir.derivatives = tempName();
  opt.pipeline.type = 'preproc';
  opt.verbosity = 0;

  opt.taskName = {'overtverbgeneration', 'linebisection'};

  opt = checkOptions(opt);

  opt.subjects = {'01', '02', '03', '10'};

  filename = bidsQA(opt);

  assertEqual(exist(filename, 'file'), 2);

end
