function test_suite = test_specifyDummyContrasts %#ok<*STOUT>
  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_specifyDummyContrasts_basic()

  contrasts = struct('C', [], 'name', []);
  counter = 0;

  SPM.xX.name = {'Sn(1) fw*bf(1)', ...
                 'Sn(1) sfw*bf(1)', ...
                 'Sn(1) bw*bf(1)', ...
                 'Sn(1) sbw*bf(1)', ...
                 'Sn(1) ld*bf(1)', ...
                 'Sn(1) sld*bf(1)', ...
                 'Sn(1) response*bf(1)', ...
                 'Sn(1) rot_x', ...
                 'Sn(1) rot_y', ...
                 'Sn(1) rot_z', ...
                 'Sn(1) trans_x', ...
                 'Sn(1) trans_y', ...
                 'Sn(1) trans_z', ...
                 'Sn(1) constant'};

  SPM.xX.X = rand(3, numel(SPM.xX.name));

  model_file = fullfile(getTestDataDir(), 'models', 'model-bug815_smdl.json');
  model = BidsModel('file', model_file, 'verbose', true);

  node.Name = 'subject_level';
  node.DummyContrasts.Test = 't';
  node.Level = 'Subject';
  node.GroupBy = {'contrast', 'subject'};
  node.Model.X = 1;

  model.SPM = SPM;

  contrasts = specifyDummyContrasts(model, node, contrasts, counter);

  assertEqual(numel({contrasts.name}), 7);

end

function test_specifyDummyContrasts_bug_815()

  contrasts = struct('C', [], 'name', []);
  counter = 0;

  SPM.xX.name = {'Sn(1) fw*bf(1)', ...
                 'Sn(1) sfw*bf(1)', ...
                 'Sn(1) bw*bf(1)', ...
                 'Sn(1) sbw*bf(1)', ...
                 'Sn(1) ld*bf(1)', ...
                 'Sn(1) sld*bf(1)', ...
                 'Sn(1) response*bf(1)', ...
                 'Sn(1) rot_x', ...
                 'Sn(1) rot_y', ...
                 'Sn(1) rot_z', ...
                 'Sn(1) trans_x', ...
                 'Sn(1) trans_y', ...
                 'Sn(1) trans_z', ...
                 'Sn(1) constant'};

  SPM.xX.X = rand(3, numel(SPM.xX.name));

  model_file = fullfile(getTestDataDir(), 'models', 'model-bug815_smdl.json');
  model = BidsModel('file', model_file, 'verbose', true);

  model.SPM = SPM;

  node = model.Nodes{2};

  contrasts = specifyDummyContrasts(model, node, contrasts, counter);

  assertEqual(numel({contrasts.name}), 7);

end

function test_specifyDummyContrasts_bug_825()

  contrasts = struct('C', [], 'name', []);
  counter = 0;

  SPM.xX.name = {
                 'Sn(1) sign_Stim1F*bf(1)'
                 'Sn(1) sign_Stim1M*bf(1)'
                 'Sn(1) sign_Stim1SCF*bf(1)'
                 'Sn(1) sign_Stim1SCM*bf(1)'
                 'Sn(1) no_sign_NoStim1F*bf(1)'
                 'Sn(1) no_sign_NoStim1M*bf(1)'
                 'Sn(1) no_sign_NoStim2F*bf(1)'
                 'Sn(1) no_sign_NoStim2M*bf(1)'
                 'Sn(1) no_sign_NoStim9M*bf(1)'
                 'Sn(1) target*bf(1)'
                 'Sn(2) sign_Stim1F*bf(1)'
                 'Sn(2) sign_Stim1M*bf(1)'
                 'Sn(2) sign_Stim1SCF*bf(1)'
                 'Sn(2) sign_Stim1SCM*bf(1)'
                 'Sn(2) no_sign_NoStim1F*bf(1)'
                 'Sn(2) no_sign_NoStim1M*bf(1)'
                 'Sn(2) no_sign_NoStim2F*bf(1)'
                 'Sn(2) no_sign_NoStim2M*bf(1)'
                 'Sn(2) no_sign_NoStim3F*bf(1)'
                 'Sn(2) target*bf(1)'
                };

  SPM.Sess(1).col = 1:10;
  SPM.Sess(2).col = 11:20;

  SPM.xX.X = rand(3, numel(SPM.xX.name));

  model_file = fullfile(getTestDataDir(), 'models', 'model-bug825_smdl.json');
  model = BidsModel('file', model_file, 'verbose', true);

  model.SPM = SPM;

  node = model.Nodes{1};

  contrasts = specifyDummyContrasts(model, node, contrasts, counter);

  assertEqual(numel({contrasts.name}), 20);

end

function test_specifyDummyContrasts_subselect_contrasts()

  contrasts = struct('C', [], 'name', []);
  counter = 0;

  SPM.xX.name = {
                 'Sn(1) sign_Stim1F*bf(1)'
                 'Sn(1) sign_Stim1M*bf(1)'
                 'Sn(1) sign_Stim1SCF*bf(1)'
                 'Sn(1) sign_Stim1SCM*bf(1)'
                 'Sn(1) no_sign_NoStim1F*bf(1)'
                 'Sn(1) no_sign_NoStim1M*bf(1)'
                 'Sn(1) no_sign_NoStim2F*bf(1)'
                 'Sn(1) no_sign_NoStim2M*bf(1)'
                 'Sn(1) no_sign_NoStim9M*bf(1)'
                 'Sn(1) target*bf(1)'
                 'Sn(2) sign_Stim1F*bf(1)'
                 'Sn(2) sign_Stim1M*bf(1)'
                 'Sn(2) sign_Stim1SCF*bf(1)'
                 'Sn(2) sign_Stim1SCM*bf(1)'
                 'Sn(2) no_sign_NoStim1F*bf(1)'
                 'Sn(2) no_sign_NoStim1M*bf(1)'
                 'Sn(2) no_sign_NoStim2F*bf(1)'
                 'Sn(2) no_sign_NoStim2M*bf(1)'
                 'Sn(2) no_sign_NoStim3F*bf(1)'
                 'Sn(2) target*bf(1)'
                };

  SPM.Sess(1).col = 1:10;
  SPM.Sess(2).col = 11:20;

  SPM.xX.X = rand(3, numel(SPM.xX.name));

  model_file = fullfile(getTestDataDir(), 'models', 'model-bug825_smdl.json');
  model = BidsModel('file', model_file, 'verbose', true);

  model.SPM = SPM;

  node = model.Nodes{1};
  node.DummyContrasts.Contrasts = node.DummyContrasts.Contrasts(1);

  contrasts = specifyDummyContrasts(model, node, contrasts, counter);

  assertEqual(numel({contrasts.name}), 20);

end
