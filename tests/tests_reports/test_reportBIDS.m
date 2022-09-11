function test_suite = test_reportBIDS %#ok<*STOUT>
  %
  % (C) Copyright 2022 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_reportBIDS_basic()

  % GIVEN

  opt = setOptions('MoAE');

  % WHEN
  reportBIDS(opt);

end

function setUp()

end

function cleanUp()

end
