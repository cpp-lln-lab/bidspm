function test_suite = test_designMatrixFigureName %#ok<*STOUT>
  %
  % (C) Copyright 2022 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_designMatrixFigureName_basic()

  % GIVEN
  opt.taskName = {'audio'};
  opt.space = {'individual'};
  % WHEN
  filename = designMatrixFigureName(opt);
  % THEN
  assertEqual(filename, 'task-audio_space-individual_designmatrix.png');

end

function test_designMatrixFigureName_all_arg()

  % GIVEN
  opt.taskName = {'audio'};
  opt.space = {'individual'};
  desc = 'foo';
  subLabel = '01';
  % WHEN
  filename = designMatrixFigureName(opt, desc, subLabel);
  % THEN
  assertEqual(filename, 'sub-01_task-audio_space-individual_desc-foo_designmatrix.png');

end
