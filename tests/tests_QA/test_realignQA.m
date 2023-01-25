function test_suite = test_realignQA %#ok<*STOUT>
  % (C) Copyright 2023 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_createPialSurface_basic()

  moaeSpm12Dir = fullfile(getDummyDataDir, 'MoAE', 'derivatives', 'spm12');

  boldFile = spm_select('FPListRec', moaeSpm12Dir, '^wsub.*nii$');
  motionFile = spm_select('FPListRec', moaeSpm12Dir, '^rp_sub.*txt$');
  [confound_file, figures] = realignQA(boldFile, motionFile);

end
