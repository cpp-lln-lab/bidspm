% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_getRFXdir %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getRFXdir_basic()

  opt = setOptions('vislocalizer');
  opt.fwhm.func = 0;
  opt.fwhm.contrast = 0;

  rfxDir = getRFXdir(opt);

  expectedOutput = fullfile(getDummyDataDir('stats'), ...
                            'derivatives', 'cpp_spm-groupStats', ...
                            'task-vislocalizer_space-MNI_FWHM-0_conFWHM-0');

  assertEqual(exist(expectedOutput, 'dir'), 7);

  cleanUp(fullfile(getDummyDataDir('stats'), 'derivatives', 'cpp_spm-groupStats'));

end

function test_getRFXdir_user_specified()

  opt = setOptions('nback');
  opt.fwhm.contrast = 0;

  rfxDir = getRFXdir(opt);

  expectedOutput = fullfile(getDummyDataDir('stats'), ...
                            'derivatives', 'cpp_spm-groupStats', ...
                            'task-nback_space-MNI_FWHM-6_conFWHM-0_desc-nbackMVPA');

  assertEqual(exist(expectedOutput, 'dir'), 7);

  cleanUp(fullfile(getDummyDataDir('stats'), 'derivatives', 'cpp_spm-groupStats'));

end
