function test_suite = test_getEventSpecificationRoiGlm %#ok<*STOUT>
  %

  % (C) Copyright 2019 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

% TODO
% when contrast but no dummy contrasts

function test_getEventSpecificationRoiGlm_basic()

  % GIVEN
  [modelFile, spmFile] = setUp();

  % WHEN
  event_specification = getEventSpecificationRoiGlm(spmFile, modelFile);

  % THEN
  assertEqual(numel(event_specification), 5);

  assertEqual(event_specification(1).name, 'famous_1');
  assertEqual(event_specification(1).eventSpec, [1; 1]);
  assertEqual(event_specification(1).duration, 0);

  assertEqual(event_specification(2).name, 'famous_2');
  assertEqual(event_specification(2).eventSpec, [1; 2]);
  assertEqual(event_specification(2).duration, 0);

  assertEqual(event_specification(3).name, 'unfamiliar_1');
  assertEqual(event_specification(3).eventSpec, [1; 3]);
  assertEqual(event_specification(3).duration, 0);

  assertEqual(event_specification(4).name, 'unfamiliar_2');
  assertEqual(event_specification(4).eventSpec, [1; 4]);
  assertEqual(event_specification(4).duration, 0);

  assertEqual(event_specification(5).name, 'faces_gt_baseline');
  assertEqual(event_specification(5).eventSpec, [1 1 1 1; 1 2 3 4]);
  assertEqual(event_specification(5).duration, 0);

  cleanUp();

end

function test_getEventSpecificationRoiGlm_warning_complex_contrasts()

  if bids.internal.is_octave()
    moxunit_throw_test_skipped_exception('Octave:mixed-string-concat warning thrown');
  end

  % GIVEN
  [modelFile, spmFile] = setUp();

  % WHEN
  assertWarning(@()getEventSpecificationRoiGlm(spmFile, modelFile), ...
                'getEventSpecificationRoiGlm:notImplemented');

end

function [modelFile, spmFile] = setUp()

  spmFile = fullfile(getTestDataDir(), 'mat_files', 'SPM_facerep.mat');

  modelFile = fullfile(getFaceRepDir(), ...
                       'models', ...
                       'model-faceRepetition_smdl.json');

end

function cleanUp()

end
