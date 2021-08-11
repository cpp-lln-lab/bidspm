% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_getFFXdir %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getFFXdirBasic()

  funcFWFM = 0;
  subLabel = '01';

  opt = setOptions('vislocalizer', subLabel);
  opt.space = {'MNI'};

  expectedOutput = fullfile(fileparts(mfilename('fullpath')), 'dummyData', 'derivatives', ...
                            'cpp_spm-stats', 'sub-01', 'stats', ...
                            'task-vislocalizer_space-MNI_FWHM-0');

  ffxDir = getFFXdir(subLabel, funcFWFM, opt);

  assertEqual(exist(expectedOutput, 'dir'), 7);

end

function test_getFFXdirUserSpecified()

  funcFWHM = 6;
  subLabel = '02';

  opt = setOptions('nback', subLabel);
  opt.space = 'individual';

  ffxDir = getFFXdir(subLabel, funcFWHM, opt);

  expectedOutput = fullfile(fileparts(mfilename('fullpath')), 'dummyData', 'derivatives', ...
                            'cpp_spm-stats', 'sub-02', 'stats', ...
                            'task-nback_space-individual_FWHM-6_desc-nbackMVPA');

  assertEqual(exist(expectedOutput, 'dir'), 7);

end
