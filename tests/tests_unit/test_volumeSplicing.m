% (C) Copyright 2022 bidspm developers

function test_suite = test_volumeSplicing %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_volumeSplicing_remove_dummies()

  if bids.internal.is_octave()
    return
  end

  [inputFile, inputData] = setUp();
  outputFile = volumeSplicing(inputFile, 1:4, 'outputFile', 'foo.nii.gz');

  hdr = spm_vol(outputFile);
  assertEqual(numel(hdr), 5);
  assertEqual(spm_read_vols(hdr), inputData(:, :, :, 5:9));

  teardown(outputFile);

end

function test_volumeSplicing_overwrite_input()

  if bids.internal.is_octave()
    return
  end

  inputFile = setUp();
  outputFile = volumeSplicing(inputFile, 1:4);

  assertEqual(outputFile, inputFile);

  hdr = spm_vol(inputFile);
  assertEqual(numel(hdr), 5);

  teardown(outputFile);

end

function test_volumeSplicing_remove_middle_vol()

  if bids.internal.is_octave()
    return
  end

  [inputFile, inputData] = setUp();
  outputFile = volumeSplicing(inputFile, 2:3, 'outputFile', 'foo.nii.gz');

  hdr = spm_vol(outputFile);
  assertEqual(numel(hdr), 7);
  assertEqual(spm_read_vols(hdr), inputData(:, :, :, [1 4:9]));

  teardown(outputFile);

end

function [inputFile, inputData] = setUp()
  teardown();
  inputFile = fullfile(getTestDataDir(), 'nifti_files', 'tmp.nii.gz');
  copyfile(fullfile(getTestDataDir(), 'nifti_files', 'sub-01_task-auditory_bold.nii.gz'), ...
           inputFile);
  inputFile = gunzip(inputFile);
  inputFile = inputFile{1};
  pause(0.005);
  inputData = spm_read_vols(spm_vol(inputFile));
end

function teardown(file)
  delete(fullfile(getTestDataDir(), 'nifti_files', 'tmp*'));
  if nargin > 0 && exist(file, 'file')
    delete(file);
  end
end
