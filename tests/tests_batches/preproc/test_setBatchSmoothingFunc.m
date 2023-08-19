% (C) Copyright 2020 bidspm developers

function test_suite = test_setBatchSmoothingFunc %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchSmoothingFunc_basic()

  % TODO
  % need a test with several sessions and runs

  subLabel = '^01';

  opt = setOptions('vislocalizer', subLabel);

  opt.space = {'IXI549Space'};

  BIDS = getLayout(opt);

  % create dummy normalized file
  fileName = bids.query(BIDS, 'data', ...
                        'sub', subLabel, ...
                        'task', opt.taskName, ...
                        'extension', '.nii', ...
                        'desc', 'preproc', ...
                        'space', 'IXI549Space', ...
                        'suffix', 'bold');

  matlabbatch = {};
  [matlabbatch, srcMetadata] = setBatchSmoothingFunc(matlabbatch, BIDS, opt, subLabel);

  expectedBatch{1}.spm.spatial.smooth.fwhm = repmat(opt.fwhm.func, [1, 3]);

  expectedBatch{1}.spm.spatial.smooth.dtype = 0;
  expectedBatch{1}.spm.spatial.smooth.im = 0;
  expectedBatch{1}.spm.spatial.smooth.prefix = ...
      [spm_get_defaults('smooth.prefix'), '6'];
  expectedBatch{1}.spm.spatial.smooth.data = fileName;

  assertEqual(matlabbatch{1}.spm.spatial.smooth.data, expectedBatch{1}.spm.spatial.smooth.data);
  assertEqual(matlabbatch{1}.spm.spatial.smooth, expectedBatch{1}.spm.spatial.smooth);

  assertEqual(srcMetadata, struct('RepetitionTime', [1.5500 1.5500], ...
                                  'SliceTimingCorrected', [false false], ...
                                  'StartTime', [nan nan]));

end
