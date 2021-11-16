% (C) Copyright 2021 CPP_SPM developers

function test_suite = test_bidsRealignUnwarp() %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRealignUnwarp_basic()

  useRaw = true;
  opt = setOptions('vislocalizer', '', useRaw);

  opt.pipeline.type = 'preproc';
  opt.funcVoxelDims = [2 2 2];
  opt.useFieldmaps = false;

  bidsRealignUnwarp(opt);

end
