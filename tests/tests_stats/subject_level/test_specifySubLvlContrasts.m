function test_suite = test_specifySubLvlContrasts %#ok<*STOUT>
  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_specifySubLvlContrasts_basic()

  contrasts = struct('C', [], 'name', []);
  counter = 0;

  node.Contrasts{1} = struct('Name', 'french_gt_scrambled', ...
                             'ConditionList', {{'trial_type.fw', 'trial_type.sfw'}}, ...
                             'Weights', [1 -1], ...
                             'Test', 't');
  node.Level = 'subject';
  node.Model.X = 1;

  SPM.xX.X = rand(6, 2);
  SPM.xX.name = {'Sn(1) fw*bf(1)', 'Sn(1) sfw*bf(1)'};

  model = BidsModel('init', true);
  model.SPM = SPM;

  [contrasts, counter] = specifySubLvlContrasts(model, node, contrasts, counter);

  assertEqual(counter, 1);
  assertEqual(contrasts.C, [1 -1]);
  assertEqual(contrasts.name, 'french_gt_scrambled');

end

function test_specifySubLvlContrasts_session()

  model = setUp();

  contrasts = struct('C', [], 'name', []);
  counter = 0;

  % run / session / dataset level node do nothing
  for i = [1, 2, 4]
    node = model.Nodes{i};
    [contrastsNew, counterNew] = specifySubLvlContrasts(model, node, ...
                                                        contrasts, counter);
    assertEqual(counterNew, counter);
    assertEqual(contrastsNew, contrasts);
  end

  % subject level
  node = model.Nodes{3};
  contrasts = specifySubLvlContrasts(model, node, contrasts, counter);
  assertEqual(contrasts.name, 'ses-1_gt_ses-2-sign_Stim1F_gt_sign_Stim2F');
  assertEqual(contrasts.C, [1 -1 1 -1 0 -1 1 -1 1 0 0]);

end

function model = setUp()
  model = BidsModel('init', true);

  model.Nodes{1}.DummyContrasts.Contrasts{1} = 'sign_Stim1F';

  model.Nodes{1}.Name = 'Run';
  model.Nodes{1}.GroupBy = {'run', 'session', 'subject'};
  model.Nodes{1}.Contrasts{1}.Name = 'sign_Stim1F_gt_sign_Stim2F';
  model.Nodes{1}.Contrasts{1}.ConditionList{1} = 'sign_Stim1F';
  model.Nodes{1}.Contrasts{1}.ConditionList{2} = 'sign_Stim2F';
  model.Nodes{1}.Contrasts{1}.Weights = [1, -1];

  model.Nodes{2, 1} = model.Nodes{1};
  model.Nodes{end}.GroupBy = {'contrast', 'session', 'subject'};
  model.Nodes{end}.Model.X = 1;
  model.Nodes{end}.Model.HRF = [];
  model.Nodes{end}.Model.Options = [];
  model.Nodes{end}.Contrasts = [];
  model.Nodes{end}.DummyContrasts  = [];
  model.Nodes{end}.Name = 'Session';
  model.Nodes{end}.Level = 'session';

  model.Nodes{3, 1} = model.Nodes{2};
  model.Nodes{end}.Model.X = {1, 'session'};
  model.Nodes{end}.GroupBy = {'contrast', 'subject'};
  model.Nodes{end}.Name = 'Subject';
  model.Nodes{end}.Level = 'subject';
  model.Nodes{end}.Contrasts{1}.Name = 'ses-1_gt_ses-2';
  model.Nodes{end}.Contrasts{1}.ConditionList{1} = '1'; % ses-1
  model.Nodes{end}.Contrasts{1}.ConditionList{2} = '2'; % ses-2
  model.Nodes{end}.Contrasts{1}.Weights = [1, -1];
  model.Nodes{end}.Contrasts{1}.Test = 't';

  model.Nodes{4, 1} = model.Nodes{2};
  model.Nodes{end}.GroupBy = {'contrast'};
  model.Nodes{end}.Name = 'Dataset';
  model.Nodes{end}.Level = 'dataset';

  model.Edges{1}.Source = 'Run';
  model.Edges{1}.Destination = 'Session';

  model.Edges{2}.Source = 'Session';
  model.Edges{2}.Destination = 'Subject';

  model.Edges{3}.Source = 'Subject';
  model.Edges{3}.Destination = 'Dataset';

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

  model.SPM = SPM;
end
