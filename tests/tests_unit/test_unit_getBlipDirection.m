% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_unit_getBlipDirection %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_getBlipDirection_basic()

  input_expected = { ...
                    '', 1; ...
                    'i', 1; ...
                    'j', 1; ...
                    'y', 1; ...
                    'i-', -1; ...
                    'j-', -1; ...
                    'y-', -1 ...
                   };

  for i = 1:size(input_expected, 1)
    metadata = struct('PhaseEncodingDirection', input_expected{i, 1});
    blipDir = getBlipDirection(metadata);
    assertEqual(blipDir, input_expected{i, 2});
  end

end

function test_getBlipDirection_error()

  metadata = struct('PhaseEncodingDirection', 'a');
  assertExceptionThrown(@()getBlipDirection(metadata), ...
                        'getBlipDirection:unknownPhaseEncodingDirection');

end
