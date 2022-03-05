function test_suite = test_plotEvents %#ok<*STOUT>
  %
  % (C) Copyright 2020 CPP_SPM developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_plotEvents_synth()

  close all;

  BIDS = bids.layout(getSyntheticDataDir());

  eventsFile = bids.query(BIDS, 'data', 'task', 'nback', 'suffix', 'events');

  plotEvents(eventsFile{1});

  close all;

end

function test_plotEvents_vislocalizer()

  close all;

  opt = setOptions('vislocalizer', '01', 'pipeline', 'stats');

  eventsFile = bids.query(opt.dir.input, 'data', ...
                          'sub', opt.subjects, ...
                          'task', opt.taskName, ...
                          'suffix', 'events');

  plotEvents(eventsFile{1});

  close all;

end

function test_plotEvents_vismotion()

  close all;

  opt = setOptions('vismotion', '01', 'pipeline', 'stats');

  eventsFile = bids.query(opt.dir.input, 'data', ...
                          'sub', opt.subjects, ...
                          'task', opt.taskName, ...
                          'suffix', 'events');

  plotEvents(eventsFile{1});

  close all;

end

function test_plotEvents_ds001()

  close all;

  dataDir = getBidsExample('ds001');

  eventsFile = bids.query(dataDir, 'data', ...
                          'sub', '01', ...
                          'task', 'balloonanalogrisktask', ...
                          'suffix', 'events');

  plotEvents(eventsFile{1});

  close all;
end
