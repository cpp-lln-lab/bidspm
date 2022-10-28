function test_suite = test_renameSegmentParameter %#ok<*STOUT>
  %

  % (C) Copyright 2022 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_renameSegmentParameter_basic()

  createDummyData();

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

  segParamFiles = spm_select('FPListRec', tmpDir, '^.*_T1w_seg8.mat$');
  assertEqual(size(segParamFiles, 1), 1);

  renameSegmentParameter(BIDS, '01', opt);

  segParamFiles = spm_select('FPListRec', tmpDir, '^.*_T1w_seg8.mat$');
  assertEqual(size(segParamFiles, 1), 0);

  segParamFiles = spm_select('FPListRec', tmpDir, '^.*label-T1w_segparam.mat$');
  assertEqual(size(segParamFiles, 1), 1);

  rmdir(tmpDir, 's');

end
