function test_suite = test_createPialSurface %#ok<*STOUT>
  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_createPialSurface_basic()

  moaeSpm12Dir = fullfile(getDummyDataDir, 'MoAE', 'derivatives', 'spm12');

  grayMatterFile = spm_select('FPListRec', moaeSpm12Dir, '^c1sub.*nii$');
  whiteMatterFile = spm_select('FPListRec', moaeSpm12Dir, '^c2sub.*nii$');

  surfaceFile = createPialSurface(grayMatterFile, whiteMatterFile, ...
                                  struct('verbosity', 3));

  assertEqual(exist(surfaceFile, 'file'), 2);
  delete(surfaceFile);

end
