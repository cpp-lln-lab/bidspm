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

  markTestAs('slow');

  opt = setOptions('MoAE-preproc');

  % move test data into temp directory to test renaming
  tmpDir = tempName();
  copyfile(opt.dir.preproc, tmpDir);

  bidsDir = tmpDir;
  if bids.internal.is_octave()
    bidsDir = fullfile(tmpDir, 'bidspm-preproc');
  end

  BIDS = bids.layout(bidsDir, ...
                     'use_schema', false, ...
                     'index_dependencies', false);

  opt.dryRun = false;
  opt.verbosity = 0;

  segParamFiles = spm_select('FPListRec', tmpDir, '^.*_T1w_seg8.mat$');
  assertEqual(size(segParamFiles, 1), 1);

  renameSegmentParameter(BIDS, '01', opt);

  segParamFiles = spm_select('FPListRec', tmpDir, '^.*_T1w_seg8.mat$');
  assertEqual(size(segParamFiles, 1), 0);

  segParamFiles = spm_select('FPListRec', tmpDir, '^.*label-T1w_segparam.mat$');
  assertEqual(size(segParamFiles, 1), 1);

end
