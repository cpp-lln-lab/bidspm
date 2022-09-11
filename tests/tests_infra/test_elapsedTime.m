function test_suite = test_elapsedTime %#ok<*STOUT>
  %
  % (C) Copyright 2020 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_elapsedTime_basic()

  opt = setOptions('vislocalizer');

  [~, opt] = setUpWorkflow(opt, 'test elapsed time');

  nbIteration = numel(opt.subjects);
  runTime = [];

  for iSub = 1:nbIteration
    subLabel = opt.subjects{iSub};
    printProcessingSubject(iSub, subLabel, opt);
    subjectStart = elapsedTime(opt, 'start');
    pause(1);
    [~, runTime] = elapsedTime(opt, 'stop', subjectStart, runTime, nbIteration);
  end

  pause(1);

  cleanUpWorkflow(opt);

end
