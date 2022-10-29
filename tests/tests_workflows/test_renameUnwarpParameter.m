function test_suite = test_renameUnwarpParameter %#ok<*STOUT>
  %

  % (C) Copyright 2022 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_renameUnwarpParameter_basic()

  opt = setOptions('MoAE-preproc');

  % move test data into temp directory to test renaming
  tmpDir = fullfile(pwd, 'tmp');
  if isfolder(tmpDir)
    rmdir(tmpDir, 's');
  end
  spm_mkdir(tmpDir);
  copyfile(opt.dir.preproc, tmpDir);

  BIDS = bids.layout(tmpDir, 'use_schema', false);

  opt.dryRun = false;
  opt.verbosity = 2;

  unwarpParamFiles = spm_select('FPListRec', tmpDir, '^.*_bold_uw.mat$');
  assertEqual(size(unwarpParamFiles, 1), 1);

  renameUnwarpParameter(BIDS, '01', opt);

  unwarpParamFiles = spm_select('FPListRec', tmpDir, '^.*_bold_uw.mat$');
  assertEqual(size(unwarpParamFiles, 1), 0);

  unwarpParamFiles = spm_select('FPListRec', tmpDir, '^.*label-bold_unwarpparam.mat$');
  assertEqual(size(unwarpParamFiles, 1), 1);

  rmdir(tmpDir, 's');

end
