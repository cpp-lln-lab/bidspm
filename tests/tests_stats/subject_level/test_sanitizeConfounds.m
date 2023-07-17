function test_suite = test_sanitizeConfounds %#ok<*STOUT>
  % (C) Copyright 2023 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_sanitizeConfounds_basic()

  R = rand(3);
  names = {'foo', 'bar', 'fizz'};

  [names_out, R_out] = sanitizeConfounds(names, R);
  
  assertEqual(R, R_out);
  assertEqual(names, names_out);

end

function test_sanitizeConfounds_clean()

  R = rand(3);
  R(:,4) = [1,0,0];
  R(:,5) = [1,0,0];
  names = {'foo', 'bar', 'fizz', 'dupe_1', 'dupe_2'};

  [names_out, R_out] = sanitizeConfounds(names, R);
  
  assertEqual(R(:,[1:3, 5]), R_out);
  assertEqual(names([1:3, 5]), names_out);

end