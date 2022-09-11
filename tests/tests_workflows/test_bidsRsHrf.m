% (C) Copyright 2021 bidspm developers

function test_suite = test_bidsRsHrf %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsRsHrf_basic()

  opt = setOptions('rest');

  opt.space = 'individual';

  matlabbatch = bidsRsHrf(opt);

  assertEqual(size(matlabbatch{1}.spm.tools.rsHRF.vox_rsHRF.mask{1}, 1), 1);
  assertEqual(size(matlabbatch{1}.spm.tools.rsHRF.vox_rsHRF.images{1}, 1), 1);

end
