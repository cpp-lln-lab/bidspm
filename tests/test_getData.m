% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_getData %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getDataMetadata()

  subLabel = '01';

  opt = setOptions('vismotion', subLabel);

  [~, opt] = getData(opt, opt.dir.preproc, 'T1w');

  assert(isequal(opt.metadata.RepetitionTime, 2.3));

end

function test_getDataErrorTask()

  opt = setOptions('testTask');

  assertExceptionThrown( ...
                        @()getData(opt, opt.dir.preproc), ...
                        'getData:noMatchingTask');

end
