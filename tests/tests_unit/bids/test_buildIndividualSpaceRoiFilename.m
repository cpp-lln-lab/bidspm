function test_suite = test_buildIndividualSpaceRoiFilename %#ok<*STOUT>
  % (C) Copyright 2022 CPP_SPM developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_buildIndividualSpaceRoiFilename_basic

  defField = 'preproc/sub-01/anat/sub-01_from-IXI549Space_to-T1w_mode-image_xfm.nii';
  roiFilename = 'roi/group/wlabel-V1d_mask.nii';

  roiBidsFile = buildIndividualSpaceRoiFilename(defField, roiFilename);

  assertEqual(roiBidsFile.filename, ...
              'sub-01_space-individual_label-V1d_mask.nii');

end

function test_buildIndividualSpaceRoiFilename_entities

  defField = 'preproc/sub-01/anat/sub-01_from-IXI549Space_to-T1w_mode-image_xfm.nii';
  roiFilename = 'roi/group/wspace-MNI_atlas-wang_label-V1d_mask.nii';

  roiBidsFile = buildIndividualSpaceRoiFilename(defField, roiFilename);

  assertEqual(roiBidsFile.filename, ...
              'sub-01_space-individual_atlas-wang_label-V1d_mask.nii');

end

function test_buildIndividualSpaceRoiFilename_session

  defField = 'preproc/sub-01/ses-01/anat/sub-01_ses-01_from-IXI549Space_to-T1w_mode-image_xfm.nii';
  roiFilename = 'roi/group/whemi-L_space-MNI_atlas-wang_label-V1d_mask.nii';

  roiBidsFile = buildIndividualSpaceRoiFilename(defField, roiFilename);

  assertEqual(roiBidsFile.filename, ...
              'sub-01_ses-01_hemi-L_space-individual_atlas-wang_label-V1d_mask.nii');

end
