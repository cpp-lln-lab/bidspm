% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_getRFXdir %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getRFXdir_basic()

  opt = setOptions('vislocalizer', '', 'pipelineType', 'stats');
  opt.fwhm.func = 0;
  opt.fwhm.contrast = 0;
  opt.space = 'IXI549Space';

  rfxDir = getRFXdir(opt);

  expectedOutput = fullfile(getDummyDataDir('stats'), ...
                            'derivatives', 'cpp_spm-groupStats', ...
                            'task-vislocalizer_space-IXI549Space_FWHM-0_conFWHM-0');

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
                            'task-nback_space-IXI549Space_FWHM-6_conFWHM-6_desc-nbackMVPA');

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
                            ['task-nback_space-IXI549Space_FWHM-6_conFWHM-6', ...
                             '_desc-nbackMVPA_contrast-nback']);

  assertEqual(exist(expectedOutput, 'dir'), 7);

  cleanUp(fullfile(getDummyDataDir('stats'), 'derivatives', 'cpp_spm-groupStats'));

end
