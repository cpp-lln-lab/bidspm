function test_suite = test_getRegressorIdx %#ok<*STOUT>

  % (C) Copyright 2022 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getRegressorIdx_basic()

  SPM.xX.name = {'Sn(1) famous_1*bf(1)'
                 'Sn(1) famous_1*bf(2)'
                 'Sn(1) famous_1*bf(3)'
                 'Sn(1) famous_2*bf(1)'
                 'Sn(1) famous_2*bf(2)'
                 'Sn(1) famous_2*bf(3)'
                 'Sn(1) unfamiliar_1*bf(1)'
                 'Sn(1) unfamiliar_1*bf(2)'
                 'Sn(1) unfamiliar_1*bf(3)'
                 'Sn(1) unfamiliar_2*bf(1)'
                 'Sn(1) unfamiliar_2*bf(2)'
                 'Sn(1) unfamiliar_2*bf(3)'
                 'Sn(1) trans_x'
                 'Sn(1) trans_y'
                 'Sn(1) trans_z'
                 'Sn(1) rot_x'
                 'Sn(1) rot_y'
                 'Sn(1) rot_z'
                 'Sn(1) constant'}';

  %% convolved
  [cdtName, regIdx, status] = getRegressorIdx('trial_type.famous_1', SPM);

  assertEqual(cdtName, 'famous_1');

  expected =  false(numel(SPM.xX.name), 1);
  expected(1) = true;
  assertEqual(regIdx, expected);

  assertEqual(status, true);

  %% non convolved
  [cdtName, regIdx, status] = getRegressorIdx('trans_x', SPM);

  assertEqual(cdtName, 'trans_x');

  expected =  false(numel(SPM.xX.name), 1);
  expected(13) = true;
  assertEqual(regIdx, expected);

  assertEqual(status, true);

  %% missing
  if bids.internal.is_octave()
    return
  end
  assertWarning(@()getRegressorIdx('foo', SPM), 'getRegressorIdx:missingRegressor');

  sts = warning('QUERY', 'getRegressorIdx:missingRegressor');
  if strcmp(sts.state, 'on')
    warning('OFF', 'getRegressorIdx:missingRegressor');
  end

  [cdtName, regIdx, status] = getRegressorIdx('foo', SPM);

  assertEqual(cdtName, 'foo');

  expected =  false(numel(SPM.xX.name), 1);
  assertEqual(regIdx, expected);

  assertEqual(status, false);

end

function test_getRegressorIdx_session()
  % Check that only the regressors
  % from a specific BIDS session are returned.

  SPM.xX.name = {
                 'Sn(1) sign_Stim1F*bf(1)'
                 'Sn(1) sign_Stim2F*bf(1)'
                 'Sn(2) sign_Stim1F*bf(1)'
                 'Sn(2) sign_Stim2F*bf(1)'
                 'Sn(2) no_resp*bf(1)'
                 'Sn(3) sign_Stim1F*bf(1)'
                 'Sn(3) sign_Stim2F*bf(1)'
                 'Sn(4) sign_Stim1F*bf(1)'
                 'Sn(4) sign_Stim2F*bf(1)'
                 'Sn(5) sign_Stim1F*bf(1)'
                 'Sn(5) sign_Stim2F*bf(1)'
                };

  SPM.xY.P = [
              'sub-MSC01_ses-1_task-foo_run-1_space-MNI_desc-smth8_bold.nii,1'; ...
              'sub-MSC01_ses-1_task-foo_run-1_space-MNI_desc-smth8_bold.nii,2'; ...
              'sub-MSC01_ses-1_task-foo_run-2_space-MNI_desc-smth8_bold.nii,1'; ...
              'sub-MSC01_ses-1_task-foo_run-2_space-MNI_desc-smth8_bold.nii,2'; ...
              'sub-MSC01_ses-2_task-foo_run-1_space-MNI_desc-smth8_bold.nii,1'; ...
              'sub-MSC01_ses-2_task-foo_run-1_space-MNI_desc-smth8_bold.nii,2'; ...
              'sub-MSC01_ses-2_task-foo_run-1_space-MNI_desc-smth8_bold.nii,1'; ...
              'sub-MSC01_ses-2_task-foo_run-2_space-MNI_desc-smth8_bold.nii,2'; ...
              'sub-MSC01_ses-foo3_task-foo_space-MNI_desc-smth8_bold.nii,1   '; ...
              'sub-MSC01_ses-foo3_task-foo_space-MNI_desc-smth8_bold.nii,2   ' ...
             ];

  % ses 1 run 1
  SPM.Sess(1).row = [1, 2];
  SPM.Sess(1).col = [1, 2];
  % ses 1 run 2
  SPM.Sess(2).row = [3, 4];
  SPM.Sess(2).col = [3, 4, 5];
  % ses 2 run 1
  SPM.Sess(3).row = [5, 6];
  SPM.Sess(3).col = [6, 7];
  % ses 2 run 2
  SPM.Sess(4).row = [7, 8];
  SPM.Sess(4).col = [8, 9];
  % ses 3
  SPM.Sess(5).row = [9, 10];
  SPM.Sess(5).col = [10, 11];

  SPM.xX.X = rand(size(SPM.xY.P, 1), numel(SPM.xX.name));

  SPM = labelSpmSessWithBidsSesAndRun(SPM);

  [~, regIdx] = getRegressorIdx('sign_Stim1F', SPM);
  expected =  false(numel(SPM.xX.name), 1);
  expected([1, 3, 6, 8, 10]) = true;
  assertEqual(regIdx, expected');

  bids_ses = '1';
  [~, regIdx] = getRegressorIdx('sign_Stim1F', SPM, bids_ses);
  expected =  false(numel(SPM.xX.name), 1);
  expected([1, 3]) = true;
  assertEqual(regIdx, expected');

  bids_ses = '2';
  [~, regIdx] = getRegressorIdx('sign_Stim1F', SPM, bids_ses);
  expected =  false(numel(SPM.xX.name), 1);
  expected([6, 8]) = true;
  assertEqual(regIdx, expected');
end
