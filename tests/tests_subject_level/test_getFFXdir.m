% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_getFFXdir %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getFFXdir_basic()

  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel, 'pipelineType', 'stats');

  opt.fwhm.func = 0;

  expectedOutput = fullfile(getDummyDataDir('stats'), 'sub-01', 'stats', ...
                            'task-vislocalizer_space-IXI549Space_FWHM-0');

  ffxDir = getFFXdir(subLabel, opt);

  assertEqual(exist(expectedOutput, 'dir'), 7);

end

function test_getFFXdir_user_specified()

  subLabel = '02';

  opt = setOptions('vismotionGlobalSignal', subLabel);
  opt.space = 'individual';
  
  ffxDir = getFFXdir(subLabel, opt);

  expectedOutput = fullfile(getDummyDataDir('stats'), 'sub-02', 'stats', ...
                            'task-vismotionGlobalSignal_space-individual_FWHM-6_desc-globalSignal');

  assertEqual(exist(expectedOutput, 'dir'), 7);

end
