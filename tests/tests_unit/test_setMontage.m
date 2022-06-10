function test_suite = test_setMontage %#ok<*STOUT>
  %
  % (C) Copyright 2021 CPP_SPM developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setMontage_basic()

  result.montage.do = true;
  result.montage.background = fullfile(spm('dir'), 'canonical', 'avg152T1.nii');
  result.montage.orientation = 'axial';
  result.montage.slices = 35:3:50;

  montage = setMontage(result);

  expected.background = {fullfile(spm('dir'), 'canonical', 'avg152T1.nii')};
  expected.orientation = 'axial';
  expected.slices = 35:3:50;

  assertEqual(montage, expected);

end

function test_setMontage_no_background_for_montage()

  result.montage.background = 'aFileThatDoesNotExist.nii';

  assertExceptionThrown(@()setMontage(result), 'setMontage:backgroundImageNotFound');

end

function test_setMontage_wrong_orientation()

  result.montage.background = fullfile(spm('dir'), 'canonical', 'avg152T1.nii');
  result.montage.orientation = 'foo';

  assertExceptionThrown(@()setMontage(result), 'setMontage:unknownOrientation');

end
