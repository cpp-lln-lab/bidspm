% (C) Copyright 2020 bidspm developers

function test_suite = test_getRFXdir %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getRFXdir_ignored_desc()

  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');
  opt.fwhm.func = 0;
  opt.fwhm.contrast = 0;
  opt.space = 'IXI549Space';

  omitList = {'dataset'; ...
              'dataset level'; ...
              ' dataset level '; ...
              '-dataset-level-'; ...
              '_dataset_level_'};
  omitList = cat(1, omitList, upper(omitList));

  for i = 1:numel(omitList)

    opt.model.bm.Nodes{3}.Name = omitList{i};
    opt.model.bm.Edges{2}.Destination = omitList{i};

    ffxDir = getRFXdir(opt);

    expectedOutput = fullfile(getDummyDataDir('stats'), ...
                              'derivatives', 'cpp_spm-groupStats', ...
                              'sub-ALL_task-vislocalizer_space-IXI549Space_FWHM-0_conFWHM-0');

    assertEqual(ffxDir, expectedOutput);
    assertEqual(exist(expectedOutput, 'dir'), 7);

    cleanUp(fullfile(getDummyDataDir('stats'), 'derivatives', 'cpp_spm-groupStats'));

  end

end

function test_getRFXdir_withinGroup()

  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');
  opt.fwhm.func = 0;
  opt.fwhm.contrast = 0;
  opt.space = 'IXI549Space';

  opt.model.file = spm_file(opt.model.file, ...
                            'basename', ...
                            'model-vislocalizerWithinGroup_smdl');

  opt.model.bm = BidsModel('file', opt.model.file);

  rfxDir = getRFXdir(opt, 'within_group', 'VisMot_gt_VisStat', 'ctrl');

  %       [~, dir] = fileparts(rfxDir)

  expectedOutput = fullfile(getDummyDataDir('stats'), ...
                            'derivatives', 'cpp_spm-groupStats', ...
                            ['sub-ctrl_task-vislocalizer_space-IXI549Space_FWHM-0_conFWHM-0', ...
                             '_node-withinGroup', '_contrast-VisMotGtVisStat']);

  %       [~, dir] = fileparts(expectedOutput)

  assertEqual(exist(expectedOutput, 'dir'), 7);

  cleanUp(fullfile(getDummyDataDir('stats'), 'derivatives', 'cpp_spm-groupStats'));

end

function test_getRFXdir_basic()

  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');
  opt.fwhm.func = 0;
  opt.fwhm.contrast = 0;
  opt.space = 'IXI549Space';

  rfxDir = getRFXdir(opt);

  expectedOutput = fullfile(getDummyDataDir('stats'), ...
                            'derivatives', 'cpp_spm-groupStats', ...
                            'sub-ALL_task-vislocalizer_space-IXI549Space_FWHM-0_conFWHM-0');

  assertEqual(exist(expectedOutput, 'dir'), 7);

  cleanUp(fullfile(getDummyDataDir('stats'), 'derivatives', 'cpp_spm-groupStats'));

end

function test_getRFXdir_extra_entity()

  opt = setOptions('vismotion', '', 'pipelineType', 'stats');

  opt.model.file = spm_file(opt.model.file, 'basename', 'model-vismotion-desc-1pt6acq_smdl');
  opt.model.bm = BidsModel('file', opt.model.file);

  opt = checkOptions(opt);

  rfxDir = getRFXdir(opt);

  expectedOutput = fullfile(getDummyDataDir('stats'), ...
                            'derivatives', 'cpp_spm-groupStats', ...
                            'sub-ALL_task-vismotion_acq-1p60mm_space-IXI549Space_FWHM-6_conFWHM-0');

  assertEqual(exist(expectedOutput, 'dir'), 7);

  cleanUp(fullfile(getDummyDataDir('stats'), 'derivatives', 'cpp_spm-groupStats'));

end

function test_getRFXdir_user_specified()

  opt = setOptions('nback', '', 'pipelineType', 'stats');
  opt.fwhm.contrast = 6;
  opt.space = 'IXI549Space';

  datasetNode = opt.model.bm.get_nodes('Level', 'dataset');
  nodeName = datasetNode.Name;

  rfxDir = getRFXdir(opt, nodeName);

  expectedOutput = fullfile(getDummyDataDir('stats'), ...
                            'derivatives', 'cpp_spm-groupStats', ...
                            'sub-ALL_task-nback_space-IXI549Space_FWHM-6_conFWHM-6_node-nbackMVPA');

  assertEqual(exist(expectedOutput, 'dir'), 7);

  cleanUp(fullfile(getDummyDataDir('stats'), 'derivatives', 'cpp_spm-groupStats'));

end

function test_getRFXdir_with_contrast()

  opt = setOptions('nback', '', 'pipelineType', 'stats');
  opt.fwhm.contrast = 6;
  opt.space = 'IXI549Space';

  datasetNode = opt.model.bm.get_nodes('Level', 'dataset');
  nodeName = datasetNode.Name;

  runNode = opt.model.bm.get_nodes('Level', 'run');
  contrastName = runNode.Contrasts{1}.Name;

  rfxDir = getRFXdir(opt, nodeName, contrastName);

  expectedOutput = fullfile(getDummyDataDir('stats'), ...
                            'derivatives', 'cpp_spm-groupStats', ...
                            ['sub-ALL_task-nback_space-IXI549Space_FWHM-6_conFWHM-6', ...
                             '_node-nbackMVPA_contrast-nback']);

  assertEqual(exist(expectedOutput, 'dir'), 7);

  cleanUp(fullfile(getDummyDataDir('stats'), 'derivatives', 'cpp_spm-groupStats'));

end
