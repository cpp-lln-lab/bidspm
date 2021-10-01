% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_unit_specifyContrasts %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_specifyContrastsComplex()
  %
  % to test the generation of contrasts when there are several runs
  %

  taskName = 'motion';

  % GIVEN
  AutoContrasts{1} = 'motion';
  AutoContrasts{2} = 'static';

  Contrasts.Name = 'motion_gt_static';
  Contrasts.ConditionList = {'motion', 'static'};
  Contrasts.weights = [1, -1];

  model = returnEmptyModel;
  model.Input.task = taskName;
  model.Steps{1}.AutoContrasts = AutoContrasts;
  model.Steps{1}.Contrasts = Contrasts;
  model.Steps{2}.AutoContrasts = AutoContrasts;
  model.Steps{2}.Contrasts = Contrasts;

  SPM.xX.name = { ...
                 ' motion*bf(1)'
                 ' static*bf(1)'
                 ' motion*bf(1)'
                 ' static*bf(1)'
                 ' motion*bf(1)'
                 ' static*bf(1)'
                };

  SPM.xX.X = ones(1, numel(SPM.xX.name));

  % WHEN
  contrasts = specifyContrasts(SPM, taskName, model);

  % THEN
  names_contrast = { ...
                    'motion', [1 0 1 0 1 0]
                    'static', [0 1 0 1 0 1]
                    'motion_gt_static', [1 -1 1 -1 1 -1]
                    'motion_1', [1 0 0 0 0 0]
                    'motion_2', [0 0 1 0 0 0]
                    'motion_3', [0 0 0 0 1 0]
                    'static_1', [0 1 0 0 0 0]
                    'static_2', [0 0 0 1 0 0]
                    'static_3', [0 0 0 0 0 1]
                    'motion_gt_static_1', [1 -1 0 0 0 0]
                    'motion_gt_static_2', [0 0 1 -1 0 0]
                    'motion_gt_static_3', [0 0 0 0 1 -1]
                   };

  for i = 1:size(names_contrast, 1)
    expected(i).name = names_contrast{i, 1};
    expected(i).C = names_contrast{i, 2};
    assertEqual(contrasts(i), expected(i));
  end

end

function test_specifyContrastsVismotion()
  %
  % Note requires an SPM.mat to run
  %

  % GIVEN
  subLabel = '01';
  funcFWHM = 6;

  opt = setOptions('vismotion', subLabel);

  ffxDir = getFFXdir(subLabel, funcFWHM, opt);
  spmMatFile = cellstr(fullfile(ffxDir, 'SPM.mat'));
  load(spmMatFile{1}, 'SPM');

  model = spm_jsonread(opt.model.file);

  % WHEN
  contrasts = specifyContrasts(SPM, opt.taskName, model);

  % THEN
  expected.name = 'VisMot'; %#ok<*AGROW>
  expected.C = [1 0 0 0 0 0 0 0 0];

  expected(2).name = 'VisStat';
  expected(2).C = [0 1 0 0 0 0 0 0 0];

  expected(3).name = 'VisMot_gt_VisStat';
  expected(3).C = [1 -1 0 0 0 0 0 0 0];

  expected(4).name = 'VisStat_gt_VisMot';
  expected(4).C = [-1 1 0 0 0 0 0 0 0];

  assertEqual(contrasts, expected);

end

function test_specifyContrastsVislocalizer()
  %
  % Note requires an SPM.mat to run
  %

  % GIVEN
  subLabel = '01';
  funcFWHM = 6;

  opt = setOptions('vislocalizer', subLabel);

  ffxDir = getFFXdir(subLabel, funcFWHM, opt);
  spmMatFile = cellstr(fullfile(ffxDir, 'SPM.mat'));
  load(spmMatFile{1}, 'SPM');

  model = spm_jsonread(opt.model.file);

  % WHEN
  contrasts = specifyContrasts(SPM, opt.taskName, model);

  % THEN
  expected.name = 'VisMot_1';
  expected.C = [1 0 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisMot_&_VisStat_1';
  expected(end).C = [1 1 0 0 0 0 0 0 0];

  expected(end + 1).name =  'VisMot_&_VisStat_lt_baseline_1';
  expected(end).C = [-1 -1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisMot';
  expected(end).C = [1 0 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisStat';
  expected(end).C = [0 1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisMot_gt_VisStat';
  expected(end).C = [1 -1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisStat_gt_VisMot';
  expected(end).C = [-1 1 0 0 0 0 0 0 0];

  assertEqual(contrasts, expected);

end
