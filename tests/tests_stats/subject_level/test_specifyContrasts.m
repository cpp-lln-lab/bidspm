% (C) Copyright 2020 bidspm developers

function test_suite = test_specifyContrasts %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_specifyContrasts_bug_854()
  % no error when no contrast to build

  skipIfOctave('mixed-string-concat warning thrown');

  % GIVEN
  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel, 'pipelineType', 'stats');
  opt.model.bm = BidsModel('file', opt.model.file);

  for iNode = 1:numel(opt.model.bm.Nodes)
    if isfield(opt.model.bm.Nodes{iNode}, 'DummyContrasts')
      opt.model.bm.Nodes{iNode} = rmfield(opt.model.bm.Nodes{iNode}, 'DummyContrasts');
    end
    if isfield(opt.model.bm.Nodes{iNode}, 'Contrasts')
      opt.model.bm.Nodes{iNode} = rmfield(opt.model.bm.Nodes{iNode}, 'Contrasts');
    end
  end

  ffxDir = getFFXdir(subLabel, opt);
  spmMatFile = cellstr(fullfile(ffxDir, 'SPM.mat'));
  load(spmMatFile{1}, 'SPM');

  assertWarning(@()specifyContrasts(opt.model.bm, SPM), ...
                'specifyContrasts:noContrast');

end

function test_specifyContrasts_bug_815()

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

  contrasts = specifyContrasts(model, SPM, 'subject_level');

  assertEqual(numel({contrasts.name}), 12);

end

function test_specifyContrasts_subject_level()

  taskName = 'motion';

  % GIVEN
  DummyContrasts{1} = 'motion';
  DummyContrasts{2} = 'static';

  Contrasts.Name = 'motion_gt_static';
  Contrasts.ConditionList = {'motion', 'static'};
  Contrasts.Weights = [1, -1];
  Contrasts.Test = 't';

  model = BidsModel('init', true);

  model.Input.task = taskName;

  model.Nodes{1, 1}.DummyContrasts.Contrasts = DummyContrasts;
  model.Nodes{1, 1}.Contrasts{1} = Contrasts;
  model.Nodes{1, 1}.GroupBy = {'run', 'subject'};
  model.Nodes{1, 1}.Model.HRF.Variables = {'motion', 'static'};

  model.Nodes{2, 1} = BidsModel.empty_node('subject');
  model.Nodes{2, 1}.GroupBy = {'subject', 'contrast'};
  model.Nodes{2, 1}.DummyContrasts = struct('Test', 't');
  model.Nodes{2, 1} = rmfield(model.Nodes{2}, 'Contrasts');
  model.Nodes{2, 1}.Model.X = 1;

  SPM.Sess(1).col = [1, 2];
  % skip Sess 2 to make sure contrast naming is based on the Sess number
  SPM.Sess(3).col = [3, 4];
  SPM.Sess(4).col = [5, 6];

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
  contrasts = specifyContrasts(model, SPM);

  % THEN
  names_contrast = { ...
                    'motion_1', [1 0 0 0 0 0]
                    'motion_3', [0 0 1 0 0 0]
                    'motion_4', [0 0 0 0 1 0]
                    'static_1', [0 1 0 0 0 0]
                    'static_3', [0 0 0 1 0 0]
                    'static_4', [0 0 0 0 0 1]
                    'motion_gt_static_1', [1 -1 0 0 0 0]
                    'motion_gt_static_3', [0 0 1 -1 0 0]
                    'motion_gt_static_4', [0 0 0 0 1 -1]
                    'motion', [1 0 1 0 1 0]
                    'static', [0 1 0 1 0 1]
                    'motion_gt_static', [1 -1 1 -1 1 -1]
                   };

  assertEqual(numel(contrasts), size(names_contrast, 1));

  for i = 1:size(names_contrast, 1)
    expected(i).name = names_contrast{i, 1};
    expected(i).C = names_contrast{i, 2};
    expected(i).type = 't';
    assertEqual(contrasts(i), expected(i));
  end

end

function test_specifyContrasts_subject_level_select_node()

  taskName = 'motion';

  % GIVEN
  DummyContrasts{1} = 'motion';
  DummyContrasts{2} = 'static';

  Contrasts.Name = 'motion_gt_static';
  Contrasts.ConditionList = {'motion', 'static'};
  Contrasts.Weights = [1, -1];
  Contrasts.Test = 't';

  model = BidsModel('init', true);
  model.Nodes{2, 1} = BidsModel.empty_node('subject');
  model.Input.task = taskName;
  model.Nodes{1, 1}.DummyContrasts.Contrasts = DummyContrasts;
  model.Nodes{1, 1}.Contrasts{1} = Contrasts;
  model.Nodes{2, 1}.GroupBy = {'subject', 'contrast'};
  model.Nodes{2, 1}.DummyContrasts = struct('Test', 't');
  model.Nodes{2, 1} = rmfield(model.Nodes{2}, 'Contrasts');
  model.Nodes{2, 1}.Model.X = 1;

  SPM.Sess(1).col = [1, 2];
  % skip Sess 2 to make sure contrast naming is based on the Sess number
  SPM.Sess(3).col = [3, 4];
  SPM.Sess(4).col = [5, 6];
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
  contrasts = specifyContrasts(model, SPM, 'subject');

  % THEN
  names_contrast = {
                    'motion', [1 0 1 0 1 0]
                    'static', [0 1 0 1 0 1]
                    'motion_gt_static', [1 -1 1 -1 1 -1]
                   };

  assertEqual(numel(contrasts), size(names_contrast, 1));

  for i = 1:size(names_contrast, 1)
    expected(i).name = names_contrast{i, 1};
    expected(i).C = names_contrast{i, 2};
    expected(i).type = 't';
    assertEqual(contrasts(i), expected(i));
  end

end

function test_specifyContrasts_run_level_dummy_contrast_from_X()
  %
  % to test the generation of contrasts when there are several runs
  %

  taskName = 'motion';

  model = BidsModel('init', true);
  model.Input.task = taskName;
  model.Nodes = [];
  model.Nodes{1}.Model.X = {'motion', 'static'};
  model.Nodes{1}.Model.HRF.Variables = {'motion', 'static'};
  model.Nodes{1}.Name = 'run_level';
  model.Nodes{1}.Level = 'Run';
  model.Nodes{1}.DummyContrasts = struct('Test', 't');
  model.Nodes{1}.GroupBy = {'run', 'subject'};

  SPM.Sess(1).col = [1, 2];
  % skip Sess 2 to make sure contrast naming is based on the Sess number
  SPM.Sess(3).col = [3, 4];
  SPM.Sess(4).col = [5, 6];

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
  contrasts = specifyContrasts(model, SPM);

  % THEN
  names_contrast = { ...
                    'motion_1', [1 0 0 0 0 0]
                    'motion_3', [0 0 1 0 0 0]
                    'motion_4', [0 0 0 0 1 0]
                    'static_1', [0 1 0 0 0 0]
                    'static_3', [0 0 0 1 0 0]
                    'static_4', [0 0 0 0 0 1]
                   };

  assertEqual(numel(contrasts), size(names_contrast, 1));

  for i = 1:size(names_contrast, 1)
    expected(i).name = names_contrast{i, 1};
    expected(i).C = names_contrast{i, 2};
    expected(i).type = 't';
    assertEqual(contrasts(i), expected(i));
  end

end

function test_specifyContrasts_missing_condition_for_dummy_contrasts()

  taskName = 'motion';

  % GIVEN
  DummyContrasts{1} = 'foo';

  model = BidsModel('init', true);
  model.Input.task = taskName;
  model.Nodes = [];
  model.Nodes{1}.Level = 'Run';
  model.Nodes{1}.Name = 'Run';
  model.Nodes{1}.GroupBy = {'run', 'subject'};
  model.Nodes{1}.DummyContrasts.Contrasts = DummyContrasts;
  model.Nodes{1}.DummyContrasts.Test = 't';
  model.Nodes{1}.Model = struct('X', {{'foo', 'bar'}}, ...
                                'HRF', struct('Variables', {{'foo', 'bar'}}));

  SPM.Sess(1).col = [1, 2];

  SPM.xX.name = { ...
                 ' motion*bf(1)'
                 ' static*bf(1)'
                };

  SPM.xX.X = ones(1, numel(SPM.xX.name));

  if bids.internal.is_octave()
    moxunit_throw_test_skipped_exception(['getRegressorIdx:missingRegressor ', ...
                                          'was raised expected ', ...
                                          'specifyContrasts:noContrast']);
  end

  assertWarning(@()specifyContrasts(model, SPM), ...
                'specifyContrasts:noContrast');

end

function test_specifyContrasts_missing_condition()

  taskName = 'motion';

  % GIVEN
  Contrasts.Name = 'motion_gt_foo';
  Contrasts.ConditionList = {'motion', 'foo'};
  Contrasts.Weights = [1, -1];
  Contrasts.Test = 't';

  model = BidsModel('init', true);
  model.Input.task = taskName;
  model.Nodes = [];
  model.Nodes{1, 1}.Contrasts{1} = Contrasts;
  model.Nodes{1}.Level = 'Run';

  SPM.Sess(1).col = [1, 2];

  SPM.xX.name = { ...
                 ' motion*bf(1)'
                 ' static*bf(1)'
                };

  SPM.xX.X = ones(1, numel(SPM.xX.name));

  if bids.internal.is_octave()
    moxunit_throw_test_skipped_exception(['getRegressorIdx:missingRegressor ', ...
                                          'was raised expected ', ...
                                          'specifyContrasts:noContrast']);
  end

  assertWarning(@()specifyContrasts(model, SPM), ...
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

  model = BidsModel('init', true);
  model.Input.task = taskName;
  model.Nodes = [];
  model.Nodes{1}.DummyContrasts.Contrasts = DummyContrasts;
  model.Nodes{1}.Contrasts{1} = Contrasts;
  model.Nodes{1}.Level = 'Run';
  model.Nodes{1}.Name = 'Run';
  model.Nodes{1}.Model = struct('X', {{'motion', 'static'}}, ...
                                'HRF', struct('Variables', {{'motion', 'static'}}));
  model.Nodes{1}.GroupBy = {'run', 'subject'};

  SPM.Sess(1).col = [1, 2];
  % skip Sess 2 to make sure contrast naming is based on the Sess number
  SPM.Sess(3).col = [3, 4];
  SPM.Sess(4).col = [5, 6];
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
  contrasts = specifyContrasts(model, SPM);

  % THEN
  names_contrast = { ...
                    'motion_1', [1 0 0 0 0 0]
                    'motion_3', [0 0 1 0 0 0]
                    'motion_4', [0 0 0 0 1 0]
                    'static_1', [0 1 0 0 0 0]
                    'static_3', [0 0 0 1 0 0]
                    'static_4', [0 0 0 0 0 1]
                    'motion_gt_static_1', [1 -1 0 0 0 0]
                    'motion_gt_static_3', [0 0 1 -1 0 0]
                    'motion_gt_static_4', [0 0 0 0 1 -1]
                   };

  assertEqual(numel(contrasts), size(names_contrast, 1));

  for i = 1:size(names_contrast, 1)
    expected(i).name = names_contrast{i, 1};
    expected(i).C = names_contrast{i, 2};
    expected(i).type = 't';
    assertEqual(contrasts(i), expected(i));
  end

end

function test_specifyContrasts_vismotion()
  %
  % Note requires an SPM.mat to run
  %

  % GIVEN
  subLabel = '01';

  opt = setOptions('vismotion', subLabel, 'pipelineType', 'stats');

  ffxDir = getFFXdir(subLabel, opt);
  spmMatFile = cellstr(fullfile(ffxDir, 'SPM.mat'));
  load(spmMatFile{1}, 'SPM');

  model = BidsModel('file', opt.model.file);

  % WHEN
  contrasts = specifyContrasts(model, SPM);

  % THEN
  expected.name = 'VisMot_ses-01'; %#ok<*AGROW>
  expected.C = [1 0 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisStat_ses-01';
  expected(end).C = [0 1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisMot_gt_VisStat_ses-01';
  expected(end).C = [1 -1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisStat_gt_VisMot_ses-01';
  expected(end).C = [-1 1 0 0 0 0 0 0 0];

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

function test_specifyContrasts_vislocalizer()
  %
  % Note requires an SPM.mat to run
  %

  % GIVEN
  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel, 'pipelineType', 'stats');
  opt.model.bm = BidsModel('file', opt.model.file);

  ffxDir = getFFXdir(subLabel, opt);
  spmMatFile = cellstr(fullfile(ffxDir, 'SPM.mat'));
  load(spmMatFile{1}, 'SPM');

  model = BidsModel('file', opt.model.file);

  % WHEN
  contrasts = specifyContrasts(model, SPM);

  % THEN
  expected.name = 'VisMot_ses-01';
  expected.C = [1 0 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisStat_ses-01';
  expected(end).C = [0 1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisMot_&_VisStat_ses-01';
  expected(end).C = [1 1 0 0 0 0 0 0 0];

  expected(end + 1).name =  'VisMot_&_VisStat_lt_baseline_ses-01';
  expected(end).C = [-1 -1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisMot';
  expected(end).C = [1 0 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisStat';
  expected(end).C = [0 1 0 0 0 0 0 0 0];

  expected(end + 1).name = 'VisMot_&_VisStat';
  expected(end).C = [1 1 0 0 0 0 0 0 0];

  expected(end + 1).name =  'VisMot_&_VisStat_lt_baseline';
  expected(end).C = [-1 -1 0 0 0 0 0 0 0];

  assertEqual({contrasts.name}', {expected.name}');
  assertEqual({contrasts.C}', {expected.C}');

end
