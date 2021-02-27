function test_suite = test_getRFXdir %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getRFXdirBasic()

  funcFWHM = 0;
  conFWHM = 0;

  opt.derivativesDir = fullfile(fileparts(mfilename('fullpath')), 'dummyData');
  opt.taskName = 'funcLocalizer';

  opt = setDerivativesDir(opt);

  rfxDir = getRFXdir(opt, funcFWHM, conFWHM);

  expectedOutput = fullfile( ...
                            fileparts(mfilename('fullpath')), ...
                            'dummyData', ...
                            'derivatives', ...
                            'cpp_spm', ...
                            'group', ...
                            'rfx_task-funcLocalizer', ...
                            'rfx_funcFWHM-0_conFWHM-0');

  assertEqual(exist(expectedOutput, 'dir'), 7);

end
