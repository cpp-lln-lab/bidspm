function test_suite = test_anatQA %#ok<*STOUT>
  % (C) Copyright 2023 Remi Gau
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_createPialSurface_basic()

  moaeSpm12Dir = fullfile(getDummyDataDir, 'MoAE', 'derivatives', 'spm12');

  anatImageFile = spm_select('FPListRec', moaeSpm12Dir, '^msub.*nii$');
  grayMatterFile = spm_select('FPListRec', moaeSpm12Dir, '^c1sub.*nii$');
  whiteMatterFile = spm_select('FPListRec', moaeSpm12Dir, '^c2sub.*nii$');

  [json, fig] = anatQA(anatImageFile, grayMatterFile, whiteMatterFile);

end
