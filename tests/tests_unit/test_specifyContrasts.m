% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_specifyContrasts %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_specifyContrasts_missing_condition()
  %
  % to test the generation of contrasts when there are several runs
  %

  taskName = 'motion';

  % GIVEN
  Contrasts.Name = 'motion_gt_foo';
  Contrasts.ConditionList = {'motion', 'foo'};
  Contrasts.Weights = [1, -1];
  Contrasts.Test = 't';

  model = createEmptyStatsModel;
  model.Input.task = taskName;
  model.Nodes{1}.Contrasts = Contrasts;
  model.Nodes = model.Nodes{1};

  model.Nodes = rmfield(model.Nodes, 'DummyContrasts');

  SPM.xX.name = { ...
                 ' motion*bf(1)'
                 ' static*bf(1)'
                };

  SPM.xX.X = ones(1, numel(SPM.xX.name));

  % WHEN
  assertWarning(@()specifyContrasts(SPM, model), ...
                'specifyContrasts:noRegressorFound');

  assertExceptionThrown( ...
                        @()specifyContrasts(SPM, model), ...
                        'specifyContrasts:noContrast');

end

function test_specifyContrasts_missing_condition_for_dummy_contrasts()
  %
  % to test the generation of contrasts when there are several runs
  %

  taskName = 'motion';

  % GIVEN
  DummyContrasts{1} = 'foo';

  model = createEmptyStatsModel;
  model.Input.task = taskName;
  model.Nodes{1}.DummyContrasts.Contrasts = DummyContrasts;
  model.Nodes{1}.DummyContrasts.Test = 't';
  model.Nodes = model.Nodes{1};

  model.Nodes = rmfield(model.Nodes, 'Contrasts');

  SPM.xX.name = { ...
                 ' motion*bf(1)'
                 ' static*bf(1)'
                };

  SPM.xX.X = ones(1, numel(SPM.xX.name));

  % WHEN
  assertWarning(@()specifyContrasts(SPM, model), ...
                'specifyContrasts:noRegressorFound');

  assertExceptionThrown( ...
                        @()specifyContrasts(SPM, model), ...
                        'specifyContrasts:noContrast');

end

function test_specifyContrasts_complex()
  %
  % to test the generation of contrasts when there are several runs
  %

  taskName = 'motion';

  % GIVEN
  DummyContrasts{1} = 'motion';
  DummyContrasts{2} = 'static';

  Contrasts.Name = 'motion_gt_static';
  Contrasts.ConditionList = {'motion', 'static'};
  Contrasts.Weights = [1, -1];
  Contrasts.Test = 't';

  model = createEmptyStatsModel;
  model.Input.task = taskName;
  model.Nodes{1}.DummyContrasts.Contrasts = DummyContrasts;
  model.Nodes{1}.Contrasts = Contrasts;
  model.Nodes{2}.DummyContrasts.Contrasts = DummyContrasts;
  model.Nodes{2}.Contrasts = Contrasts;

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
  contrasts = specifyContrasts(SPM, model);

  % THEN
  names_contrast = { ...
                    'motion_1', [1 0 0 0 0 0]
                    'motion_2', [0 0 1 0 0 0]
                    'motion_3', [0 0 0 0 1 0]
                    'static_1', [0 1 0 0 0 0]
                    'static_2', [0 0 0 1 0 0]
                    'static_3', [0 0 0 0 0 1]
                    'motion_gt_static_1', [1 -1 0 0 0 0]
                    'motion_gt_static_2', [0 0 1 -1 0 0]
                    'motion_gt_static_3', [0 0 0 0 1 -1]
                    'motion', [1 0 1 0 1 0]
                    'static', [0 1 0 1 0 1]
                    'motion_gt_static', [1 -1 1 -1 1 -1]

                   };

  for i = 1:size(names_contrast, 1)
    expected(i).name = names_contrast{i, 1};
    expected(i).C = names_contrast{i, 2};
    assertEqual(contrasts(i), expected(i));
  end

end

function test_specifyContrasts_vismotion()
  %
  % Note requires an SPM.mat to run
  %

  % GIVEN
  subLabel = '01';

  opt = setOptions('vismotion', subLabel);

  opt.space = {'IXI549Space'};

  ffxDir = getFFXdir(subLabel, opt);
  spmMatFile = cellstr(fullfile(ffxDir, 'SPM.mat'));
  load(spmMatFile{1}, 'SPM');

  model = spm_jsonread(opt.model.file);

  % WHEN
  contrasts = specifyContrasts(SPM, model);

  % THEN
  expected.name = 'VisMot_1'; %#ok<*AGROW>
  expected.C = [1 0 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisStat_1';
  expected(end).C = [0 1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisMot_gt_VisStat_1';
  expected(end).C = [1 -1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisStat_gt_VisMot_1';
  expected(end).C = [-1 1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisMot'; %#ok<*AGROW>
  expected(end).C = [1 0 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisStat';
  expected(end).C = [0 1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisMot_gt_VisStat';
  expected(end).C = [1 -1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisStat_gt_VisMot';
  expected(end).C = [-1 1 0 0 0 0 0 0 0];

  assertEqual({contrasts.name}', {expected.name}');
  assertEqual({contrasts.C}', {expected.C}');

end

function test_specifyContrasts_vislocalizer()
  %
  % Note requires an SPM.mat to run
  %

  % GIVEN
  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel);

  opt.space = {'IXI549Space'};

  ffxDir = getFFXdir(subLabel, opt);
  spmMatFile = cellstr(fullfile(ffxDir, 'SPM.mat'));
  load(spmMatFile{1}, 'SPM');

  model = spm_jsonread(opt.model.file);

  % WHEN
  contrasts = specifyContrasts(SPM, model);

  % THEN
  expected.name = 'VisMot_1';
  expected.C = [1 0 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisStat_1';
  expected(end).C = [0 1 0 0 0 0 0 0 0];

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

  assertEqual({contrasts.name}', {expected.name}');
  assertEqual({contrasts.C}', {expected.C}');

end
