function test_suite = test_specifyDummyContrasts_Session %#ok<*STOUT>
  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_specifyDummyContrasts_session()

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

  model = BidsModel('init', true);
  model.SPM = SPM;

  model.Nodes{1}.DummyContrasts.Contrasts{1} = 'sign_Stim1F';
  model.Nodes{1}.GroupBy = {'run', 'subject'};
  model.Nodes{1}.Model.X = {'sign_Stim1F', 'sign_Stim2F', 'no_resp'};
  model.Nodes{1}.Model.HRF.Variables = {'sign_Stim1F', 'sign_Stim2F', 'no_resp'};

  model.Nodes{2, 1} = model.Nodes{1};
  model.Nodes{end}.Name = 'Session';
  model.Nodes{end}.Level = 'session';
  model.Nodes{end}.GroupBy = {'contrast', 'session', 'subject'};
  model.Nodes{end}.Contrasts = [];

  model = model.get_edges_from_nodes();

  node = model.Nodes{1};
  contrasts = struct('C', [], 'name', []);
  counter = 0;
  contrasts = specifyDummyContrasts(model, node, contrasts, counter);
  assertEqual(numel({contrasts.name}), 5);

  node = model.Nodes{2};
  contrasts = struct('C', [], 'name', []);
  counter = 0;

  contrasts = specifyDummyContrasts(model, node, contrasts, counter);
  assertEqual(numel({contrasts.name}), 3);

end
