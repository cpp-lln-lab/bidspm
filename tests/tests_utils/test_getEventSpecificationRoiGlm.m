function test_suite = test_getEventSpecificationRoiGlm %#ok<*STOUT>
  %
  % (C) Copyright 2019 CPP_SPM developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_getEventSpecificationRoiGlm_basic()

  % GIVEN
  [modelFile, spmFile] = setUp();

  % WHEN
  event_specification = getEventSpecificationRoiGlm(spmFile, modelFile);

  % THEN
  assertEqual(event_specification(1).name, 'F1');
  assertEqual(event_specification(1).event_spec, [1; 1]);
  assertEqual(event_specification(1).duration, 0);

  assertEqual(event_specification(2).name, 'F2');
  assertEqual(event_specification(2).event_spec, [1; 2]);
  assertEqual(event_specification(2).duration, 0);

  assertEqual(event_specification(3).name, 'N1');
  assertEqual(event_specification(3).event_spec, [1; 3]);
  assertEqual(event_specification(3).duration, 0);

  assertEqual(event_specification(4).name, 'N2');
  assertEqual(event_specification(4).event_spec, [1; 4]);
  assertEqual(event_specification(4).duration, 0);

  cleanUp();

end

function [modelFile, spmFile] = setUp()

  spmFile = fullfile(getDummyDataDir(), 'mat_files', 'SPM_facerep.mat');

  modelFile = fullfile(getFaceRepDir(), ...
                       'models', ...
                       'model-faceRepetition_smdl.json');

end

function cleanUp()

end
