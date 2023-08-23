function test_suite = test_concatenateConfounds %#ok<*STOUT>
  % (C) Copyright 2023 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_concatenateConfounds_basic()

  tempPath = tempDir();

  %% run 1
  names =  {'rot_x',    'trans_x', 'csf',     'white'};
  R =      rand(6, 4);
  regressorsFile1 = fullfile(tempPath, 'sub-01_ses-01_task-fiz_run-1_timeseries.mat');
  save(regressorsFile1, 'names', 'R', '-v7');
  sess(1).multi_reg = {regressorsFile1};

  % only one run does nothing
  matFile = concatenateConfounds(sess);

  assertEqual(matFile, regressorsFile1);

  %% run 2
  names =  {'rot_x',    'trans_x',  'motion_1'};
  R =      [rand(4, 2), [1; zeros(3, 1)]];
  regressorsFile2 = fullfile(tempPath, 'sub-01_ses-02_task-buzz_run-1_timeseries.mat');
  save(regressorsFile2, 'names', 'R', '-v7');
  sess(2).multi_reg = {regressorsFile2};

  matFile = concatenateConfounds(sess);

  %
  assertEqual(exist(matFile, 'file'), 2);

  [~, filename] = fileparts(matFile);
  assertEqual(filename, 'sub-01_task-fizBuzz_desc-confounds_timeseries');

  assertEqual(exist(regressorsFile1, 'file'), 0);
  assertEqual(exist(regressorsFile2, 'file'), 0);

  load(matFile, 'names', 'R');

  assertEqual(names, {'csf'    'motion_1'    'rot_x'    'trans_x'    'white'});
  assertEqual(size(R), [10, 5]);
  assertEqual(R(:, 2), [zeros(6, 1); 1; zeros(3, 1)]);

end
