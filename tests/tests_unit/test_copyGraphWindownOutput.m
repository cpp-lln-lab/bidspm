% (C) Copyright 2020 bidspm developers

function test_suite = test_copyGraphWindownOutput %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_copyGraphWindownOutput_basic()

  [opt, subLabel, action] = setUp();

  imgNb = 1:2;

  system('touch spm_001.png');
  system('touch spm_002.png');

  imgNb = copyGraphWindownOutput(opt, subLabel, action, imgNb);

  assertEqual(imgNb, 3);

  files = spm_select( ...
                     'List', ...
                     fullfile(opt.dir.preproc, ['sub-' subLabel], 'figures'), ...
                     ['^' datestr(now, 'yyyymmddHH') '.*_[0-9]_sub-01_task-dummy_testStep.png']);

  assert(~isempty(files));
  assertEqual(size(files, 1), 2);

  cleanUp(fullfile(opt.dir.preproc, ['sub-' subLabel]));

end

function test_copyGraphWindownOutput_warning()

  if bids.internal.is_octave()
    return
  end

  [opt, subLabel, action] = setUp();
  opt.verbosity = 1;

  system('touch spm_002.png');
  system('touch spm_test_002.png');

  assertWarning( ...
                @()copyGraphWindownOutput(opt, subLabel, action, 2), ...
                'copyGraphWindownOutput:tooManyFiles');

  assertWarning( ...
                @()copyGraphWindownOutput(opt, subLabel, action, 3), ...
                'copyGraphWindownOutput:noFile');

  cleanUp(fullfile(opt.dir.preproc, ['sub-' subLabel]));

end

function [opt, subLabel, action] = setUp()

  delete('*.png');

  pause(1);

  subLabel = '01';

  opt = setOptions('dummy', subLabel);
  opt.verbosity = 0;
  opt.dir.preproc = pwd;

  action = 'testStep';

end
