% (C) Copyright 2020 CPP_SPM developers

function test_suite = test_computeMeanValueInMask %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_computeMeanValueInMask_basic()

  opt = setOptions('MoAE');

  BIDS = bids.layout(opt.dir.preproc);

  boldImage = bids.query(BIDS, 'data', 'suffix', 'T1w');

  value = computeMeanValueInMask(boldImage, mask);

  assertEqual(size(volTsnr), [64, 64, 64]);

end
