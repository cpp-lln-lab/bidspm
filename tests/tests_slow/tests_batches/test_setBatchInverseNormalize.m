function test_suite = test_setBatchInverseNormalize %#ok<*STOUT>
  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBatchInverseNormalize_basic()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  subLabel = '^01';

  opt = setOptions('vismotion', subLabel);

  BIDS = getLayout(opt);

  imgToResample = {'foo'};

  matlabbatch = {};
  matlabbatch = setBatchInverseNormalize(matlabbatch, BIDS, opt, subLabel, imgToResample);

  deformationField = fullfile(BIDS.pth, 'sub-01', 'ses-01', 'anat', ...
                              'sub-01_ses-01_from-IXI549Space_to-T1w_mode-image_xfm.nii');

  assertEqual(matlabbatch{1}.spm.spatial.normalise.write.subj.def(1), {deformationField});
  assertEqual(matlabbatch{1}.spm.spatial.normalise.write.woptions.vox, nan(1, 3));
  assertEqual(matlabbatch{1}.spm.spatial.normalise.write.subj.resample(1), {'foo'});
  assertEqual(matlabbatch{1}.spm.spatial.normalise.write.woptions.bb, nan(2, 3));

end

function test_setBatchInverseNormalize_warning()

  opt = setOptions('vismotion');

  opt.verbosity = 1;

  BIDS = getLayout(opt);
  subLabel = '99';
  imgToResample = {'foo'};
  matlabbatch = {};
  assertWarning(@()setBatchInverseNormalize(matlabbatch, BIDS, opt, subLabel, imgToResample), ...
                'setBatchInverseNormalize:noDeformationField');

end
