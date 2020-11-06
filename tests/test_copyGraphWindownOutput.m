function test_suite = test_copyGraphWindownOutput %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_copyGraphWindownOutputBasic()
  
  opt.derivativesDir = pwd;
  opt.taskName = 'testTask';
  subID = '01';
  imgNb = 1:2;
  action = 'testStep';
  
  system('touch spm_001.png');
  system('touch spm_002.png');
  
  imgNb = copyGraphWindownOutput(opt, subID, action, imgNb);
  
  assertEqual(imgNb, 3)
  
  files = spm_select(...
    'List', ...
    fullfile(opt.derivativesDir, ['sub-' subID], 'figures'), ...
    ['^' datestr(now, 'yyyymmddHH') '.*_[0-9]_sub-01_task-testTask_testStep.png']);
  
  assert(~isempty(files));
  assertEqual(size(files, 1), 2);
  
  pause(1)
  rmdir(fullfile(opt.derivativesDir, ['sub-' subID]), 's')
  
end