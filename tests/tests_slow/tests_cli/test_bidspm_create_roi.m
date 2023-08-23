function test_suite = test_bidspm_create_roi %#ok<*STOUT>

  % (C) Copyright 2023 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_bidsCreateROI_boilerplate_only()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  if bids.internal.is_octave
    moxunit_throw_test_skipped_exception('Need bug fix in CPP ROI extractRoiFromAtlas.');
  end

  outputPath = tempName();

  bidspm(pwd, outputPath, ...
         'subject', ...
         'action', 'create_roi', ...
         'roi_atlas', 'glasser', ...
         'roi_name', {'OFC'}, ...
         'boilerplate_only', true, ...
         'space', {'IXI549Space'}, ...
         'verbosity', 0);

  assert(exist(fullfile(outputPath, ...
                        'derivatives', ...
                        'bidspm-roi', ...
                        'reports', ...
                        'create_roi_atlas-glasser_citation.md'), 'file') == 2);

end

function test_bidsCreateROI_glasser()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  if bids.internal.is_octave
    moxunit_throw_test_skipped_exception('Need bug fix in CPP ROI extractRoiFromAtlas.');
  end

  outputPath = tempName();

  bidspm(pwd, outputPath, ...
         'subject', ...
         'action', 'create_roi', ...
         'roi_atlas', 'glasser', ...
         'roi_name', {'OFC'}, ...
         'space', {'IXI549Space'}, ...
         'verbosity', 3);

  rois = spm_select('FPList', fullfile(outputPath, ...
                                       'derivatives', ...
                                       'bidspm-roi', 'group'), '.*glasser.*_mask\.nii');
  assert(size(rois, 1) == 2);

end

function test_bidsCreateROI_wang()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  if bids.internal.is_octave
    moxunit_throw_test_skipped_exception('Need bug fix in CPP ROI extractRoiFromAtlas.');
  end

  outputPath = tempName();

  bidspm(pwd, outputPath, ...
         'subject', ...
         'action', 'create_roi', ...
         'roi_atlas', 'wang', ...
         'roi_name', {'V1v', 'V1d'}, ...
         'space', {'IXI549Space'}, ...
         'verbosity', 0);

  rois = spm_select('FPList', fullfile(outputPath, ...
                                       'derivatives', ...
                                       'bidspm-roi', 'group'), '.*wang.*_mask\.nii');
  assert(size(rois, 1) == 4);

end

function test_bidsCreateROI_neuromorphometrics()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  if bids.internal.is_octave
    moxunit_throw_test_skipped_exception('Need bug fix in CPP ROI extractRoiFromAtlas.');
  end

  outputPath = tempName();

  bidspm(pwd, outputPath, ...
         'subject', ...
         'action', 'create_roi', ...
         'roi_atlas', 'neuromorphometrics', ...
         'roi_name', {'SCA subcallosal area'}, ...
         'space', {'IXI549Space'}, ...
         'verbosity', 0);

  rois = spm_select('FPList', fullfile(outputPath, ...
                                       'derivatives', ...
                                       'bidspm-roi', 'group'), '.*neuromorphometrics.*_mask\.nii');
  assert(size(rois, 1) == 2);

end

function test_bidsCreateROI_neuromorphometrics_inv_norm()

  moxunit_throw_test_skipped_exception('Requires some deformation field to work');

  %   if ~bids.internal.is_github_ci()
  %
  %     bidspm(pwd, fullfile(pwd, 'tmp'), ...
  %            'subject', ...
  %            'action', 'create_roi', ...
  %            'roi_atlas', 'neuromorphometrics', ...
  %            'roi_name', {'SCA subcallosal area'}, ...
  %            'space', {'individual'}, ...
  %            'verbosity', 0);
  %
  %   end

end

function test_bidsCreateROI_one_hemisphere()

  if ~usingSlowTestMode()
    moxunit_throw_test_skipped_exception('slow test only');
  end

  if bids.internal.is_octave
    moxunit_throw_test_skipped_exception('Need bug fix in CPP ROI extractRoiFromAtlas.');
  end

  outputPath = tempName();

  bidspm(pwd, outputPath, 'subject', ...
         'action', 'create_roi', ...
         'verbosity', 0, ...
         'roi_atlas', 'visfatlas', ...
         'hemisphere', {'L'}, ...
         'roi_name', {'OTS', 'ITG', 'MTG', 'LOS', 'pOTS', 'IOS'}, ...
         'space', {'IXI549Space'});

  rois = spm_select('FPList', fullfile(outputPath, ...
                                       'derivatives', ...
                                       'bidspm-roi', 'group'), '.*visfatlas.*_mask\.nii');
  assert(size(rois, 1) == 6);

end
