% (C) Copyright 2022 CPP_SPM developers

function test_suite = test_volumeSplicing %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

% TODO add content checks

function test_volumeSplicing_remove_dummies()

  inputFile = setUp();
  outputFile = volumeSplicing(inputFile, 1:4, 'outputFile', 'foo.nii.gz');

  hdr = spm_vol(outputFile);
  assertEqual(numel(hdr), 5);

  teardown(outputFile);

end

function test_volumeSplicing_overwrite_input()

  inputFile = setUp();
  outputFile = volumeSplicing(inputFile, 1:4);

  assertEqual(outputFile, inputFile);

  hdr = spm_vol(inputFile);
  assertEqual(numel(hdr), 5);

  teardown(outputFile);

end

function test_volumeSplicing_remove_middle_vol()

  inputFile = setUp();
  outputFile = volumeSplicing(inputFile, 2:3, 'outputFile', 'foo.nii.gz');

  hdr = spm_vol(outputFile);
  assertEqual(numel(hdr), 7);

  teardown(outputFile);

end

function inputFile = setUp()
  teardown();
  inputFile = fullfile(getDummyDataDir(), 'nifti_files', 'tmp.nii.gz');
  copyfile(fullfile(getDummyDataDir(), 'nifti_files', 'sub-01_task-auditory_bold.nii.gz'), ...
           inputFile);
end

function teardown(file)
  delete(fullfile(getDummyDataDir(), 'nifti_files', 'tmp*'));
  if nargin > 0 && exist(file, 'file')
    delete(file);
  end
end
