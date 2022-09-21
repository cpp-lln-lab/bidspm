function test_suite = test_reorderCounfounds %#ok<*STOUT>
  %

  % (C) Copyright 2022 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_reorderCounfounds_missing()

  % GIVEN
  allConfoundsNames =  {'trans_x', 'rot_x', 'rot_y', 'rot_z'};
  names = {'trans_x', 'rot_z', 'rot_x'};
  R = rand(6, 3);

  expected = [R(:, 3) zeros(6, 1) R(:, [2, 1])];

  % WHEN
  [names, R] = reorderCounfounds(names, R, allConfoundsNames);

  % THEN
  assertEqual(R, expected);
  assertEqual(names, {'rot_x', 'dummyConfound', 'rot_z', 'trans_x'});

end

function test_reorderCounfounds_basic()

  % GIVEN
  allConfoundsNames =  {'rot_x', 'rot_y', 'rot_z'};
  names = {'rot_z', 'rot_x', 'rot_y'};
  R = rand(6, 3);

  expected = R(:, [2, 3, 1]);

  % WHEN
  [names, R] = reorderCounfounds(names, R, allConfoundsNames);

  % THEN
  assertEqual(names, allConfoundsNames);
  assertEqual(R, expected);

end

function test_reorderCounfounds_duplicate_should_not_matter()

  % GIVEN
  allConfoundsNames =  {'rot_x', 'rot_y', 'rot_z', 'rot_x'};
  names = {'rot_z', 'rot_x', 'rot_y'};
  R = rand(6, 3);

  expected = R(:, [2, 3, 1]);

  % WHEN
  [names, R] = reorderCounfounds(names, R, allConfoundsNames);

  % THEN
  assertEqual(names, {'rot_x', 'rot_y', 'rot_z'});
  assertEqual(R, expected);

end

function test_reorderCounfounds_error()

  % GIVEN
  allConfoundsNames =  {'rot_x'};
  names = {'rot_z', 'rot_x', 'rot_y'};
  R = rand(6, 3);

  % WHEN
  assertExceptionThrown(@()reorderCounfounds(names, R, allConfoundsNames), ...
                        'reorderCounfounds:missingConfounds');

end

function test_reorderCounfounds_sort_even_if_reference_list_not_ordered()

  % GIVEN
  allConfoundsNames =  {'rot_z', 'rot_y', 'rot_x'};
  names = {'rot_z', 'rot_x', 'rot_y'};
  R = rand(6, 3);

  expected = R(:, [2, 3, 1]);

  % WHEN
  [names, R] = reorderCounfounds(names, R, allConfoundsNames);

  % THEN
  assertEqual(names, {'rot_x', 'rot_y', 'rot_z'});
  assertEqual(R, expected);

end
