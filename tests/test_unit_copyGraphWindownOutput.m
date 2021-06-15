% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_unit_copyGraphWindownOutput %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_copyGraphWindownOutputBasic()

  [opt, subLabel, action] = setUp();

  imgNb = 1:2;

  system('touch spm_001.png');
  system('touch spm_002.png');

  imgNb = copyGraphWindownOutput(opt, subLabel, action, imgNb);

  assertEqual(imgNb, 3);

  files = spm_select( ...
                     'List', ...
                     fullfile(opt.dir.preproc, ['sub-' subLabel], 'figures'), ...
                     ['^' datestr(now, 'yyyymmddHH') '.*_[0-9]_sub-01_task-testTask_testStep.png']);

  assert(~isempty(files));
  assertEqual(size(files, 1), 2);

  cleanUp(opt, subLabel);

end

function test_copyGraphWindownOutputWarning1()

  [opt, subLabel, action] = setUp();
  opt.verbosity = 1;

  system('touch spm_002.png');
  system('touch spm_test_002.png');

  if ~isOctave()
    assertWarning( ...
                  @()copyGraphWindownOutput(opt, subLabel, action, 2), ...
                  'copyGraphWindownOutput:tooManyFiles');

    assertWarning( ...
                  @()copyGraphWindownOutput(opt, subLabel, action, 3), ...
                  'copyGraphWindownOutput:noFile');
  end

  cleanUp(opt, subLabel);

end

function [opt, subLabel, action] = setUp()

  delete('*.png');

  pause(1);

  subLabel = '01';

  opt = setOptions('testTask', subLabel);
  opt.verbosity = 0;
  opt.dir.preproc = pwd;

  action = 'testStep';

end

function cleanUp(opt, subLabel)

  pause(1);

  if isOctave()
    confirm_recursive_rmdir (true, 'local');
  end
  rmdir(fullfile(opt.dir.preproc, ['sub-' subLabel]), 's');

end
