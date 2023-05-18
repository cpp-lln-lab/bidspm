function test_suite = test_bidspm_create_roi %#ok<*STOUT>

  % (C) Copyright 2023 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_bidsCreateROI_glasser()

  outputPath = tmpName();

  bidspm(pwd, outputPath, ...
         'subject', ...
         'action', 'create_roi', ...
         'roi_atlas', 'glasser', ...
         'roi_name', {'OFC'}, ...
         'space', {'IXI549Space'}, ...
         'verbosity', 0);

  cleanUp(fullfile(pwd, 'options'));
  cleanUp(fullfile(pwd, 'error_logs'));

end

function test_bidsCreateROI_wang()

  outputPath = tmpName();

  bidspm(pwd, outputPath, ...
         'subject', ...
         'action', 'create_roi', ...
         'roi_atlas', 'wang', ...
         'roi_name', {'V1v', 'V1d'}, ...
         'space', {'IXI549Space'}, ...
         'verbosity', 0);

  cleanUp(fullfile(pwd, 'options'));
  cleanUp(fullfile(pwd, 'error_logs'));

end

function test_bidsCreateROI_visfatlas()

  outputPath = tmpName();

  bidspm(pwd, tmpName(), ...
         'subject', ...
         'action', 'create_roi', ...
         'roi_atlas', 'visfatlas', ...
         'roi_name', {'OTS'}, ...
         'space', {'IXI549Space'}, ...
         'verbosity', 0);

  cleanUp(fullfile(pwd, 'options'));
  cleanUp(fullfile(pwd, 'error_logs'));
end

function test_bidsCreateROI_neuromorphometrics()

  outputPath = tmpName();

  bidspm(pwd, outputPath, ...
         'subject', ...
         'action', 'create_roi', ...
         'roi_atlas', 'neuromorphometrics', ...
         'roi_name', {'SCA subcallosal area'}, ...
         'space', {'IXI549Space'}, ...
         'verbosity', 0);

  cleanUp(fullfile(pwd, 'options'));
  cleanUp(fullfile(pwd, 'error_logs'));

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
  %   cleanUp(fullfile(pwd, 'tmp'));
  %   cleanUp(fullfile(pwd, 'options'));
  %   cleanUp(fullfile(pwd, 'error_logs'));
  %
  %   end

end

function test_bidsCreateROI_one_hemisphere()

  if bids.internal.is_octave
    moxunit_throw_test_skipped_exception('Need bug fix in CPP ROI extractRoiFromAtlas.');
  end

  outputPath = tmpName();

  bidspm(pwd, outputPath, 'subject', ...
         'action', 'create_roi', ...
         'verbosity', 0, ...
         'roi_atlas', 'visfatlas', ...
         'hemisphere', {'L'}, ...
         'roi_name', {'OTS', 'ITG', 'MTG', 'LOS', 'pOTS', 'IOS'}, ...
         'space', {'IXI549Space'});
  assertEqual(size(spm_select('FPListRec', ...
                              outputPath, ...
                              '.*mask.nii'), 1), ...
              6);

  cleanUp(fullfile(pwd, 'options'));
  cleanUp(fullfile(pwd, 'error_logs'));
end

function pth = tmpName()
  pth = tempname();
  mkdir(pth);
end
