function test_suite = test_reorderCounfounds %#ok<*STOUT>
  %
  % (C) Copyright 2022 CPP_SPM developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

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
