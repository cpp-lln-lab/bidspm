% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsRemoveDummies %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRemoveDummies_basic()

  opt = setOptions('MoAE');
  bidsRemoveDummies(opt, 'dummyScans', 12, 'force', false);

end
