% (C) Copyright 2022 CPP_SPM developers

function test_suite = test_returnNameSkullstripOutput %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_returnNameSkullstripOutput_basic()

  inputFile = 'sub-001_T1w.nii';

  image = returnNameSkullstripOutput(inputFile, 'image');
  assertEqual(image, 'sub-001_space-individual_desc-skullstripped_T1w.nii');

  mask = returnNameSkullstripOutput(inputFile, 'mask');
  assertEqual(mask, 'sub-001_space-individual_label-brain_mask.nii');

end

function test_returnNameSkullstripOutput_oops()

  inputFile = 'sub-001_acq-r0p375_desc-skullstripped_UNIT1.nii';

  image = returnNameSkullstripOutput(inputFile, 'image');
  assertEqual(image, 'sub-001_acq-r0p375_space-individual_desc-skullstripped_UNIT1.nii');

  mask = returnNameSkullstripOutput(inputFile, 'mask');
  assertEqual(mask, 'sub-001_acq-r0p375_space-individual_label-brain_mask.nii');

end
