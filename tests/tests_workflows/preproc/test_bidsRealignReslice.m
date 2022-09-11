% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsRealignReslice %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRealignReslice_basic()

  opt = setOptions('vislocalizer', '');

  opt.funcVoxelDims = [2 2 2];

  bidsRealignReslice(opt);

end
