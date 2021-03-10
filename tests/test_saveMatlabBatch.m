% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function test_suite = test_saveMatlabBatch %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_saveMatlabBatchBasic()

  opt.jobsDir = pwd;
  subID = '01';
  matlabbatch = struct('test', 1);

  expectedOutput = fullfile(pwd, 'sub-01', ...
                            [datestr(now, 'yyyymmdd_HHMM') ...
                             '_jobs_matlabbatch_SPM12_test.mat']);

  saveMatlabBatch(matlabbatch, 'test', opt, subID);

  assertEqual(exist(expectedOutput, 'file'), 2);

end

function test_saveMatlabBatchGroup()

  opt.jobsDir = pwd;
  matlabbatch = struct('test', 1);

  expectedOutput = fullfile(pwd, 'group', ...
                            [datestr(now, 'yyyymmdd_HHMM') ...
                             '_jobs_matlabbatch_SPM12_groupTest.mat']);

  saveMatlabBatch(matlabbatch, 'groupTest', opt);

  assertEqual(exist(expectedOutput, 'file'), 2);

end
