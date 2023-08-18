function test_suite = test_bidsSmoothContrasts %#ok<*STOUT>
  % (C) Copyright 2023 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_bidsSmoothContrasts_basic()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  opt.fwhm.contrast = 6;

  matlabbatch = bidsSmoothContrasts(opt);
  assertEqual(numel(matlabbatch), 3); % one batch per subject

  assertEqual(matlabbatch{1}.spm.spatial.smooth.fwhm, ...
              repmat(opt.fwhm.contrast, [1, 3]));

  onlyConImag = regexp(matlabbatch{1}.spm.spatial.smooth.data, ...
                       '^.*con_[0-9]{4}.nii$');
  assert(all(cellfun(@(x) x == 1, onlyConImag)));

end

function test_bidsSmoothContrasts_zero_fwhm()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  opt = setOptions('vislocalizer',  '', 'pipelineType', 'stats');

  opt.fwhm.contrast = 0;

  matlabbatch = bidsSmoothContrasts(opt);
  assert(isempty(matlabbatch));

end
