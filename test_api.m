% (C) Copyright 2022 bidspm developers

function testSuite = test_api %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_api_basic()

  % initialise (add relevant folders to path)
  bidspm;
  bidspm('action', 'uninit');
  bidspm('action', 'init');
  bidspm('action', 'uninit');

  % also adds folder for testing to the path
  bidspm('action', 'dev');
  bidspm('action', 'uninit');

  % misc
  bidspm('action', 'version');

end
