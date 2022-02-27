% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_model %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_model_basic()

  opt = setOptions('narps');

  bm = Model('file', opt.model.file);

  assertEqual(bm.Name, 'NARPS');
  assertEqual(bm.Description, 'NARPS Analysis model');
  assertEqual(bm.BIDSModelVersion, '1.0.0');
  assertEqual(bm.Input, struct('task', 'MGT'));
  assertEqual(bm.Edges{1}, struct('Source', 'run', 'Destination', 'subject'));

end
