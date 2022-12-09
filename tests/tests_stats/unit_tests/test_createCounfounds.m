% (C) Copyright 2021 bidspm developers

function test_suite = test_createCounfounds %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_createConfounds_no_nans()

  tsvFile = fullfile(getDummyDataDir, ...
                     'tsv_files', ...
                     'sub-01_task-test_desc-confounds_regressors.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  designMatrix = {'trial_type.VisMot'
                  'trial_type.VisStat'
                  'trial_type.missing_condition'
                  'trans_*'
                  'rot_*'};

  [~, R] = createConfounds(tsvContent, designMatrix);

  assertEqual(sum(isnan(R(:))), 0);

end

function test_createConfounds_maxNbVols()

  tsvFile = fullfile(getDummyDataDir, ...
                     'tsv_files', ...
                     'sub-01_task-test_desc-confounds_regressors.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  designMatrix = {'trial_type.VisMot'
                  'trial_type.VisStat'
                  'trial_type.missing_condition'
                  'trans_x'
                  'trans_y'
                  'trans_z'
                  'rot_x'
                  'rot_y'
                  'rot_z'};

  [~, R] = createConfounds(tsvContent, designMatrix, 200);

  assertEqual(size(R, 1), 200);

end

function test_createConfounds_maxNbVols_gt_actualNbVols()

  tsvFile = fullfile(getDummyDataDir, ...
                     'tsv_files', ...
                     'sub-01_task-test_desc-confounds_regressors.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  designMatrix = {'trial_type.VisMot'
                  'trial_type.VisStat'
                  'trial_type.missing_condition'
                  'trans_x'
                  'trans_y'
                  'trans_z'
                  'rot_x'
                  'rot_y'
                  'rot_z'};

  [~, R] = createConfounds(tsvContent, designMatrix, 400);

  assertEqual(size(R, 1), 283);

end

function test_createConfounds_outlier_regressors()

  tsvFile = fullfile(getDummyDataDir, ...
                     'tsv_files', ...
                     'sub-01_task-test_desc-confounds_regressors.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  designMatrix = {'trial_type.VisMot'
                  'trial_type.VisStat'
                  'trial_type.missing_condition'
                  'rot_x'
                  'rot_y'
                  'rot_z'
                  'trans_x'
                  'trans_y'
                  'trans_z'
                  'non_steady_state_outlier*'
                  'motion_outlier*'};

  names = createConfounds(tsvContent, designMatrix, Inf);

  expectedNames = {'rot_x'
                   'rot_y'
                   'rot_z'
                   'trans_x'
                   'trans_y'
                   'trans_z'
                   'non_steady_state_outlier00'
                   'non_steady_state_outlier01'
                   'non_steady_state_outlier02'
                   'motion_outlier00'
                   'motion_outlier01'};

  assertEqual(names, expectedNames);
end

function test_createConfounds_regex()

  tsvFile = fullfile(getDummyDataDir, ...
                     'tsv_files', ...
                     'sub-01_task-test_desc-confounds_regressors.tsv');
  tsvContent = bids.util.tsvread(tsvFile);

  designMatrix = {'trial_type.VisMot'
                  'trial_type.VisStat'
                  'trial_type.missing_condition'
                  'trans_?'
                  'rot_?'
                  '*outlier*'};

  names = createConfounds(tsvContent, designMatrix, Inf);

  expectedNames = {'trans_x'
                   'trans_y'
                   'trans_z'
                   'rot_x'
                   'rot_y'
                   'rot_z'
                   'non_steady_state_outlier00'
                   'non_steady_state_outlier01'
                   'non_steady_state_outlier02'
                   'motion_outlier00'
                   'motion_outlier01'};

  assertEqual(names, expectedNames);

end
