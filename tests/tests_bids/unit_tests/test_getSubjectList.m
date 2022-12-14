% (C) Copyright 2020 bidspm developers

function test_suite = test_getSubjectList %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getSubject_regex()

  opt = setOptions('vismotion', '');

  BIDS = getLayout(opt);

  group_subject_expected = {
                            {''}, {'.*01'}, {'01', 'blind01', 'ctrl01'}
                            {''}, {'01'}, {'01', 'blind01', 'ctrl01'}
                            {''}, {'^01'}, {'01'}
                           };

  for i = 1:size(group_subject_expected, 1)
    opt.groups = group_subject_expected{i, 1};
    opt.subjects = group_subject_expected{i, 2};

    opt = getSubjectList(BIDS, opt);

    assertEqual(opt.subjects, group_subject_expected{i, 3}');
  end

end

function test_getSubject()

  opt = setOptions('vismotion', '');

  BIDS = getLayout(opt);

  group_subject_expected = {
                            {''},      {'blind01', 'ctrl01'}, {'blind01', 'ctrl01'}  % basic
                            {''},      'ctrl01',              {'ctrl01'}  % convert_to_cell
                            {''},      [],                    {'01' 'blind01' 'ctrl01'}  % default
                            {'blind'}, 'ctrl01',              {'01', 'blind01', 'ctrl01'}
                           };

  for i = 1:size(group_subject_expected, 1)
    opt.groups = group_subject_expected{i, 1};
    opt.subjects = group_subject_expected{i, 2};

    opt = getSubjectList(BIDS, opt);

    assertEqual(opt.subjects, group_subject_expected{i, 3}');
  end

end

function test_getSubjectList_error_subject()

  opt = setOptions('vismotion', '03');

  BIDS = getLayout(opt);

  assertExceptionThrown( ...
                        @()getSubjectList(BIDS, opt), ...
                        'getSubjectList:noMatchingSubject');

end
