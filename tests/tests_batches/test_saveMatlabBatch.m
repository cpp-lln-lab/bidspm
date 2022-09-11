% (C) Copyright 2020 bidspm developers

function test_suite = test_saveMatlabBatch %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_saveMatlabBatch_basic()

  subLabel = '01';
  opt = setOptions('dummy', subLabel);
  opt.dryRun = false;
  opt.dir.jobs = pwd;

  matlabbatch = struct('test', 1);
  saveMatlabBatch(matlabbatch, 'test', opt, subLabel);

  expectedOutput = fullfile(pwd, ['sub-' subLabel], ...
                            ['batch_test_' datestr(now, 'yyyy-mm-ddTHH-MM') '.mat']);

  assertEqual(exist(expectedOutput, 'file'), 0);
  assertEqual(exist(spm_file(expectedOutput, 'ext', '.json'), 'file'), 2);

  expectedOutput = fullfile(pwd, ['sub-' subLabel], ...
                            ['batch_test_' datestr(now, 'yyyy_mm_ddTHH_MM') '.m']);

  assertEqual(exist(expectedOutput, 'file'), 2);

  cleanUp(fullfile(pwd, ['sub-' subLabel]));

end

function test_saveMatlabBatch_group()

  subLabel = '01';
  opt = setOptions('dummy', subLabel);
  opt.dryRun = false;
  opt.dir.jobs = pwd;

  matlabbatch = struct('test', 1);

  expectedOutput = fullfile(pwd, 'group', ...
                            ['batch_groupTest_' datestr(now, 'yyyy-mm-ddTHH-MM') '.mat']);

  saveMatlabBatch(matlabbatch, 'groupTest', opt);

  assertEqual(exist(expectedOutput, 'file'), 0);
  assertEqual(exist(spm_file(strrep(expectedOutput, '-', '_'), 'ext', '.m'), 'file'), 2);

  cleanUp(fullfile(pwd, 'group'));

end
