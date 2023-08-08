function test_suite = test_labelSpmSessWithBidsSesAndRun %#ok<*STOUT>
  % (C) Copyright 2023 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_labelSpmSessWithBidsSesAndRun_basic()

  SPM.Sess(1).row = [1, 2]; % ses 1 run 1
  SPM.Sess(2).row = [3, 4]; % ses 1 run 2
  SPM.Sess(3).row = [5, 6]; % ses 2 run 1
  SPM.Sess(4).row = [7, 8]; % ses 2 run 2
  SPM.Sess(5).row = [9, 10];  % ses 3

  SPM.xX.name = {
                 'Sn(1) sign_Stim1F*bf(1)'
                 'Sn(2) sign_Stim1F*bf(1)'
                 'Sn(3) sign_Stim1F*bf(1)'
                 'Sn(4) sign_Stim1F*bf(1)'
                 'Sn(5) sign_Stim1F*bf(1)'
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

  SPM = labelSpmSessWithBidsSesAndRun(SPM);
  assertEqual({SPM.Sess.run}, {'1', '2', '1', '1', ''});
  assertEqual({SPM.Sess.ses}, {'1', '1', '2', '2', 'foo3'});

end
