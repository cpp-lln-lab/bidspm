function test_suite = test_computeDesignEfficiency %#ok<*STOUT>
  % (C) Copyright 2021 CPP_SPM developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_computeDesignEfficiency_vislocalizer()

  close all;

  opt = setOptions('vismotion', '01');

  BIDS = bids.layout(opt.dir.input);

  metadata = bids.query(BIDS, 'metadata', ...
                        'sub', opt.subjects, ...
                        'task', opt.taskName, ...
                        'suffix', 'bold');

  opt.TR = metadata{1}.RepetitionTime;
  opt.t0 = 1;

  opt.Ns = 25;

  eventsFile = bids.query(BIDS, 'data', ...
                          'sub', opt.subjects, ...
                          'task', opt.taskName, ...
                          'suffix', 'events');

  computeDesignEfficiency(eventsFile{1}, opt);

end
