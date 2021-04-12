% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function test_suite = test_unit_copyGraphWindownOutput %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_copyGraphWindownOutputBasic()

  delete('*.png');

  pause(1);

  opt.derivativesDir = pwd;
  opt.taskName = 'testTask';
  subID = '01';
  imgNb = 1:2;
  action = 'testStep';

  system('touch spm_001.png');
  system('touch spm_002.png');

  imgNb = copyGraphWindownOutput(opt, subID, action, imgNb);

  assertEqual(imgNb, 3);

  files = spm_select( ...
                     'List', ...
                     fullfile(opt.derivativesDir, ['sub-' subID], 'figures'), ...
                     ['^' datestr(now, 'yyyymmddHH') '.*_[0-9]_sub-01_task-testTask_testStep.png']);

  assert(~isempty(files));
  assertEqual(size(files, 1), 2);

  pause(1);

  if isOctave()
    confirm_recursive_rmdir (true, 'local');
  end
  rmdir(fullfile(opt.derivativesDir, ['sub-' subID]), 's');

end

function test_copyGraphWindownOutputWarning()

  delete('*.png');

  pause(1);

  opt.derivativesDir = pwd;
  opt.taskName = 'testTask';
  subID = '01';
  action = 'testStep';

  system('touch spm_002.png');
  system('touch spm_test_002.png');

  copyGraphWindownOutput(opt, subID, action, 2);

  if ~isOctave()
    assertWarning( ...
                  @()copyGraphWindownOutput(opt, subID, action, 2), ...
                  'copyGraphWindownOutput:tooManyFiles');

    assertWarning( ...
                  @()copyGraphWindownOutput(opt, subID, action, 3), ...
                  'copyGraphWindownOutput:noFile');
  end

  if isOctave()
    confirm_recursive_rmdir (true, 'local');
  end
  rmdir(fullfile(opt.derivativesDir, ['sub-' subID]), 's');

end
