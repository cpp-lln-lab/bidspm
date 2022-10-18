% (C) Copyright 2020 bidspm developers

function test_suite = test_setBatchSmoothingAnat %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchSmoothingAnat_basic()

  subLabel = '^01';

  opt = setOptions('vislocalizer', subLabel);

  opt.space = {'IXI549Space'};
  opt.bidsFilterFile.t1w.label = {'CSF', 'GM', 'WM'};
  opt.bidsFilterFile.t1w.suffix = 'probseg';

  BIDS = getLayout(opt);

  % create dummy normalized file
  fileName = bids.query(BIDS, 'data', ...
                        'sub', subLabel, ...
                        'extension', '.nii', ...
                        'space', 'IXI549Space', ...
                        'label', {'CSF', 'GM', 'WM'}, ...
                        'modality', 'anat');

  matlabbatch = {};
  matlabbatch = setBatchSmoothingAnat(matlabbatch, BIDS, opt, subLabel);

  expectedBatch{1}.spm.spatial.smooth.fwhm = repmat(opt.fwhm.func, [1, 3]);

  expectedBatch{1}.spm.spatial.smooth.dtype = 0;
  expectedBatch{1}.spm.spatial.smooth.im = 0;
  expectedBatch{1}.spm.spatial.smooth.prefix = ...
      [spm_get_defaults('smooth.prefix'), '6'];
  expectedBatch{1}.spm.spatial.smooth.data = fileName;

  assertEqual(matlabbatch{1}.spm.spatial.smooth.data, expectedBatch{1}.spm.spatial.smooth.data);
  assertEqual(matlabbatch{1}.spm.spatial.smooth, expectedBatch{1}.spm.spatial.smooth);

end
