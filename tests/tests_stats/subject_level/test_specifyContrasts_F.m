% (C) Copyright 2020 bidspm developers

function test_suite = test_specifyContrasts_F %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_specifyContrasts_subject_level_F_contrast()
  %
  % to test the generation of F contrasts when there are several runs
  %

  taskName = 'motion';

  model = BidsModel('init', true);

  model.Input.task = taskName;

  model.Nodes{1, 1}.Model.X = {'motion', 'static'};
  model.Nodes{end}.Level = 'Run';
  model.Nodes{end}.Name = 'run_level';
  model.Nodes{end}.GroupBy = {'run', 'subject'};
  model.Nodes{end} = rmfield(model.Nodes{1}, 'Contrasts');
  model.Nodes{end} = rmfield(model.Nodes{1}, 'DummyContrasts');

  model.Nodes{2, 1}.Model.X = 1;
  model.Nodes{end}.Level = 'Subject';
  model.Nodes{end}.Name = 'subject_level';
  model.Nodes{end}.GroupBy = {'contrast', 'subject'};
  model.Nodes{end}.Contrasts{1} = struct('Test', 'F', ...
                                         'Name', 'F_test_mot_static', ...
                                         'ConditionList', {{'motion', 'static'}}, ...
                                         'Weights', [1, 0
                                                     0, 1]);

  SPM.Sess(1).col = [1, 2, 3];
  % skip Sess 2 to make sure contrast naming is based on the Sess number
  SPM.Sess(3).col = [4, 5, 6];
  SPM.Sess(4).col = [7, 8, 9];
  SPM.xX.name = { ...
                 ' motion*bf(1)'
                 ' static*bf(1)'
                 ' rot_x'
                 ' motion*bf(1)'
                 ' static*bf(1)'
                 ' rot_x'
                 ' motion*bf(1)'
                 ' static*bf(1)'
                 ' rot_x'
                };

  SPM.xX.X = ones(1, numel(SPM.xX.name));

  % WHEN
  contrasts = specifyContrasts(model, SPM);

  % THEN
  expected.name =  'F_test_mot_static';

  expected.C = zeros(6, 9);
  expected.C(1, 1) = 1;
  expected.C(2, 4) = 1;
  expected.C(3, 7) = 1;
  expected.C(4, 2) = 1;
  expected.C(5, 5) = 1;
  expected.C(6, 8) = 1;

  expected.type = 'F';

  assertEqual(contrasts, expected);

end

function test_specifyContrasts_vismotion_F_contrast()
  %
  % Note requires an SPM.mat to run
  %

  % GIVEN
  subLabel = '01';

  opt = setOptions('vismotion', subLabel, 'pipelineType', 'stats');

  ffxDir = getFFXdir(subLabel, opt);
  spmMatFile = cellstr(fullfile(ffxDir, 'SPM.mat'));
  load(spmMatFile{1}, 'SPM');

  opt.model.file = spm_file(opt.model.file, 'basename', 'model-vismotionFtest_smdl');
  model = BidsModel('file', opt.model.file);

  % WHEN
  contrasts = specifyContrasts(model, SPM);

  % THEN
  expected(1).name = 'VisMot_gt_VisStat_ses-01'; %#ok<*AGROW>
  expected(1).C = [1 -1 0 0 0 0 0 0 0];
  expected(1).type = 't';

  expected(2).name = 'F_test_mot_static_ses-01'; %#ok<*AGROW>
  expected(2).C = [1 0 0 0 0 0 0 0 0
                   0 1 0 0 0 0 0 0 0];
  expected(2).type = 'F';

  assertEqual(contrasts, expected);

end
