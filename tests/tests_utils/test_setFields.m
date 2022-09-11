% (C) Copyright 2020 bidspm developers

function test_suite = test_setFields %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setFields_write()

  %% set up
  structure = struct();

  fieldsToSet.field = 1;

  structure = setFields(structure, fieldsToSet);

  %% data to test against
  expectedStructure.field = 1;

  %% test
  assertEqual(expectedStructure, structure);

end

function test_setFields_no_overwrite()

  % set up
  structure.field.subfield_1 = 3;

  fieldsToSet.field.subfield_1 = 1;
  fieldsToSet.field.subfield_2 = 1;

  structure = setFields(structure, fieldsToSet);

  % data to test against
  expectedStructure.field.subfield_1 = 3;
  expectedStructure.field.subfield_2 = 1;

  % test
  assert(isequal(expectedStructure, structure));

end

function test_setFields_overwrite()

  overwrite = true();

  % set up
  structure.field.subfield_1 = 3;

  fieldsToSet.field.subfield_1 = 1;
  fieldsToSet.field.subfield_2 = 1;

  structure = setFields(structure, fieldsToSet, overwrite);

  % data to test against
  expectedStructure.field.subfield_1 = 1;
  expectedStructure.field.subfield_2 = 1;

  % test
  assert(isequal(expectedStructure, structure));

end

function test_setFields_cmplx_struct()

  % set up
  structure = struct();

  fieldsToSet.field.subfield_1 = 1;
  fieldsToSet.field.subfield_2(1).name = 'a';
  fieldsToSet.field.subfield_2(1).value = 1;
  fieldsToSet.field.subfield_2(2).name = 'b';
  fieldsToSet.field.subfield_2(2).value = 2;

  structure = setFields(structure, fieldsToSet);

  % data to test against
  expectedStructure.field.subfield_1 = 1;
  expectedStructure.field.subfield_2(1).name = 'a';
  expectedStructure.field.subfield_2(1).value = 1;
  expectedStructure.field.subfield_2(2).name = 'b';
  expectedStructure.field.subfield_2(2).value = 2;

  % test
  assert(isequal(expectedStructure, structure));

end
