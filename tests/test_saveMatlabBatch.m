% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_saveMatlabBatch %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_saveMatlabBatchBasic()

  subLabel = '01';
  opt = setOptions('dummy', subLabel);
  opt.dir.jobs = pwd;

  matlabbatch = struct('test', 1);

  expectedOutput = fullfile(pwd, ['sub-' subLabel], ...
                            [datestr(now, 'yyyymmdd_HHMM') ...
                             '_jobs_matlabbatch_SPM12_test.mat']);

  saveMatlabBatch(matlabbatch, 'test', opt, subLabel);

  assertEqual(exist(expectedOutput, 'file'), 2);

  cleanUp(fullfile(pwd, ['sub-' subLabel]));

end

function test_saveMatlabBatchGroup()

  subLabel = '01';
  opt = setOptions('dummy', subLabel);
  opt.dir.jobs = pwd;

  matlabbatch = struct('test', 1);

  expectedOutput = fullfile(pwd, 'group', ...
                            [datestr(now, 'yyyymmdd_HHMM') ...
                             '_jobs_matlabbatch_SPM12_groupTest.mat']);

  saveMatlabBatch(matlabbatch, 'groupTest', opt);

  assertEqual(exist(expectedOutput, 'file'), 2);

  cleanUp(fullfile(pwd, 'group'));

end

function cleanUp(folder)

  pause(1);

  if isOctave()
    confirm_recursive_rmdir (true, 'local');
  end
  rmdir(folder, 's');

end
