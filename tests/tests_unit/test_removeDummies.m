% (C) Copyright 2022 bidspm developers

function test_suite = test_removeDummies %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_removeDummies_basic()

  inputFile = setUp();
  removeDummies(inputFile, 4);

  hdr = spm_vol(inputFile);
  assertEqual(numel(hdr), 5);

  [pth, file] = spm_fileparts(inputFile);
  expectedJsonFile = fullfile(pth, spm_file(file, 'ext', 'json'));
  assertEqual(exist(expectedJsonFile, 'file'), 2);

  metadata = bids.util.jsondecode(expectedJsonFile);
  assertEqual(metadata.NumberOfVolumesDiscardedByUser, 4);

  teardown();

end

function test_removeDummies_not_force()

  inputFile = setUp();
  metadata.NumberOfVolumesDiscardedByUser = 10;

  assertWarning(@()removeDummies(inputFile, 4, metadata), ...
                'removeDummies:dummiesAlreadyRemoved');

  teardown();

end

function test_removeDummies_force()

  inputFile = setUp();
  metadata.NumberOfVolumesDiscardedByUser = 10;
  removeDummies(inputFile, 4, metadata, 'force', true);

  [pth, file] = spm_fileparts(inputFile);
  expectedJsonFile = fullfile(pth, spm_file(file, 'ext', 'json'));
  metadata = bids.util.jsondecode(expectedJsonFile);
  assertEqual(metadata.NumberOfVolumesDiscardedByUser, 14);

  teardown();

end

function inputFile = setUp()
  teardown();
  inputFile = fullfile(getDummyDataDir(), 'nifti_files', 'tmp.nii.gz');
  copyfile(fullfile(getDummyDataDir(), 'nifti_files', 'sub-01_task-auditory_bold.nii.gz'), ...
           inputFile);
end

function teardown()
  delete(fullfile(getDummyDataDir(), 'nifti_files', 'tmp*'));
end
