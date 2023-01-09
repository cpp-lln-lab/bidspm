% (C) Copyright 2020 bidspm developers

function test_suite = test_saveOptions %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_saveOptions_basic()

  opt = setOptions('dummy');

  saveOptions(opt);

  expected = fullfile(opt.dir.derivatives, 'options', ['options_task-dummy_' timeStamp()  '.json']);

  assertEqual(exist(expected, 'file'), 2);

  cleanUp(fullfile(opt.dir.derivatives, 'options'));

end
