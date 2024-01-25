function test_suite = test_copyGraphWindownOutput %#ok<*STOUT>
  % (C) Copyright 2020 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_copyGraphWindownOutput_basic()

  [opt, subLabel, action, PWD] = setUp();

  imgNb = 1:2;

  touch(fullfile(opt.dir.preproc, 'spm_001.png'));
  touch(fullfile(opt.dir.preproc, 'spm_002.png'));

  imgNb = copyGraphWindownOutput(opt, subLabel, action, imgNb);

  assertEqual(imgNb, 3);

  files = spm_select('List', ...
                     fullfile(opt.dir.preproc, ['sub-' subLabel], 'figures'), ...
                     ['^' datestr(now, 'yyyymmddHH') '.*_[0-9]_sub-01_task-dummy_testStep.png']);

  assert(~isempty(files));
  assertEqual(size(files, 1), 2);

  cd(PWD);

end

function test_copyGraphWindownOutput_warning()

  skipIfOctave('mixed-string-concat warning thrown');

  [opt, subLabel, action, PWD] = setUp();
  opt.verbosity = 1;

  touch(fullfile(opt.dir.preproc, 'spm_002.png'));
  touch(fullfile(opt.dir.preproc, 'spm_test_002.png'));

  assertWarning(@()copyGraphWindownOutput(opt, subLabel, action, 2), ...
                'copyGraphWindownOutput:tooManyFiles');

  assertWarning(@()copyGraphWindownOutput(opt, subLabel, action, 3), ...
                'copyGraphWindownOutput:noFile');

  cd(PWD);

end

function [opt, subLabel, action, PWD] = setUp()

  PWD = pwd;

  subLabel = '01';

  opt = setOptions('dummy', subLabel);
  opt.verbosity = 0;
  opt.dir.preproc = tempName();

  action = 'testStep';

  cd(opt.dir.preproc);

end
