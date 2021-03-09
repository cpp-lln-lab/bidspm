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
  opt = setDerivativesDir(opt);
  opt = checkOptions(opt);

  expectedOutput = fullfile(fileparts(mfilename('fullpath')), 'dummyData', 'derivatives', ...
                            'cpp_spm', 'sub-01', 'stats', 'ffx_task-funcLocalizer', ...
                            'ffx_space-MNI_FWHM-0');

  ffxDir = getFFXdir(subLabel, funcFWFM, opt);

  assertEqual(exist(expectedOutput, 'dir'), 7);

end

function test_getFFXdirMvpa()

  funcFWFM = 6;
  subLabel = '02';

  opt = setOptions('nBack', subLabel);
  opt.space = 'individual';
  opt = setDerivativesDir(opt);
  opt = checkOptions(opt);

  expectedOutput = fullfile(fileparts(mfilename('fullpath')), 'dummyData', 'derivatives', ...
                            'cpp_spm', 'sub-02', 'stats', 'ffx_task-nBack', ...
                            'ffx_space-individual_FWHM-6');

  ffxDir = getFFXdir(subLabel, funcFWFM, opt);

  assertEqual(exist(expectedOutput, 'dir'), 7);

end
