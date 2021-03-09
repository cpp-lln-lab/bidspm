function test_suite = test_specifyContrasts %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_specifyContrastsBasic()
  % Small test to ensure that pmCon returns what we asked for

  subLabel = '01';
  funcFWFM = 6;

  opt = setOptions('vismotion', subLabel);
  opt = checkOptions(opt);
  opt = setDerivativesDir(opt);

  opt.model.file = ...
      fullfile(fileparts(mfilename('fullpath')), ...
               'dummyData', 'models', 'model-visMotionLoc_smdl.json');

  ffxDir = getFFXdir(subLabel, funcFWFM, opt);

  contrasts = specifyContrasts(ffxDir, opt.taskName, opt);

  assert(strcmp(contrasts(1).name, 'VisMot'));
  assert(isequal(contrasts(1).C, [1 0 0 0 0 0 0 0 0]));

  assert(strcmp(contrasts(2).name, 'VisStat'));
  assert(isequal(contrasts(2).C, [0 1 0 0 0 0 0 0 0]));

  assert(strcmp(contrasts(3).name, 'VisMot_gt_VisStat'));
  assert(isequal(contrasts(3).C, [1 -1 0 0 0 0 0 0 0]));

  assert(strcmp(contrasts(4).name, 'VisStat_gt_VisMot'));
  assert(isequal(contrasts(4).C, [-1 1 0 0 0 0 0 0 0]));

end
