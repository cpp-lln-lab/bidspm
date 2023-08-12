% (C) Copyright 2020 bidspm developers

function test_suite = test_getFFXdir %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getFFXdir_ignored_desc()

  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel, 'pipelineType', 'stats');

  opt.fwhm.func = 0;

  omitList = {'run'; ...
              'run level'; ...
              ' run level '; ...
              '-run-level-'; ...
              '_run_level_'};
  omitList = cat(1, omitList, upper(omitList));

  for i = 1:numel(omitList)

    opt.model.bm.Nodes{1}.Name = omitList{i};
    opt.model.bm.Edges{1}.Source = omitList{i};

    ffxDir = getFFXdir(subLabel, opt);

    expectedOutput = fullfile(getTestDataDir('stats'), 'sub-01', ...
                              'task-vislocalizer_space-IXI549Space_FWHM-0');

    assertEqual(ffxDir, expectedOutput);
    assertEqual(exist(expectedOutput, 'dir'), 0);
  end

end

function test_getFFXdir_basic()

  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel, 'pipelineType', 'stats');

  opt.fwhm.func = 0;

  expectedOutput = fullfile(getTestDataDir('stats'), 'sub-01', ...
                            'task-vislocalizer_space-IXI549Space_FWHM-0');

  ffxDir = getFFXdir(subLabel, opt);

  assertEqual(ffxDir, expectedOutput);
  assertEqual(exist(expectedOutput, 'dir'), 0);

end

function test_getFFXdir_extra_entity()

  subLabel = '^01';

  opt = setOptions('vismotion', subLabel, 'pipelineType', 'stats');

  opt.model.file = spm_file(opt.model.file, 'basename', 'model-vismotion-desc-1pt6acq_smdl');
  opt.model.bm = BidsModel('file', opt.model.file);

  opt = checkOptions(opt);

  ffxDir = getFFXdir(subLabel, opt);

  expectedOutput = fullfile(getTestDataDir('stats'), 'sub-01', ...
                            'task-vismotion_acq-1p60mm_space-IXI549Space_FWHM-6');

  assertEqual(ffxDir, expectedOutput);

end

function test_getFFXdir_user_specified()

  subLabel = '02';

  opt = setOptions('vismotionGlobalSignal', subLabel, 'pipelineType', 'stats');
  opt.space = 'individual';

  ffxDir = getFFXdir(subLabel, opt);

  expectedOutput = fullfile(getTestDataDir('stats'), 'sub-02', ...
                            'task-vismotion_space-individual_FWHM-6_node-globalSignal');

  assertEqual(ffxDir, expectedOutput);

end
