% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_getSubjectList %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getSubject_convert_to_cell()

  opt = setOptions('vismotion');

  opt.subjects = 'ctrl01';

  BIDS = bids.layout(opt.dir.preproc);

  %% Get all groups all subjects
  opt = getSubjectList(BIDS, opt);

  assertEqual(opt.subjects, ...
              {'ctrl01'});

end

function test_getSubject_no_subject_specified()

  opt = setOptions('vismotion');

  BIDS = bids.layout(opt.dir.preproc);

  %% Get all groups all subjects
  opt = getSubjectList(BIDS, opt);

  assertEqual(opt.subjects, ...
              {'01' '02' 'blind01' 'blind02' 'ctrl01' 'ctrl02'}');

end

function test_getSubjectList_group()

  opt = setOptions('vismotion');

  BIDS = bids.layout(opt.dir.preproc);

  %% Get all subjects of a group and a subject from another group
  opt.groups = {'blind'};
  opt.subjects = {'ctrl01'};

  opt = getSubjectList(BIDS, opt);

  % 'sub-02' is defined a blind in the participants.tsv
  assertEqual(opt.subjects, {'02', 'blind01', 'blind02', 'ctrl01'}');

end

function test_getSubjectList_basic()

  opt = setOptions('vismotion');

  BIDS = bids.layout(opt.dir.preproc);

  %% Get some specified subjects
  opt.groups = {''};
  opt.subjects = {'01', '02'; 'ctrl02', 'blind02'};

  opt = getSubjectList(BIDS, opt);

  assertEqual(opt.subjects, {'01', '02', 'blind02', 'ctrl02'}');

end

function test_getSubjectList_error_subject()

  opt = setOptions('vismotion', '03');

  BIDS = bids.layout(opt.dir.preproc);

  assertExceptionThrown( ...
                        @()getSubjectList(BIDS, opt), ...
                        'getSubjectList:noMatchingSubject');

end
