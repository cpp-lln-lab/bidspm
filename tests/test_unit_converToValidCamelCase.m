% (C) Copyright 2021 CPP BIDS SPM-pipeline developers

function test_suite = test_unit_converToValidCamelCase %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_converToValidCamelCaseBasic()

  str = 'foo bar';
  str = converToValidCamelCase(str);
  assertEqual(str, 'fooBar');

  %% set up

  str = '&|@#-_(!{})01[]%+/=:;.?,\<> visual task';
  str = converToValidCamelCase(str);
  assertEqual(str, '01VisualTask');

end
