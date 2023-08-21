function test_suite = test_transferMetadataFromJson %#ok<*STOUT>
  % (C) Copyright 2023 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_transferMetadataFromJson_basic()

  sourceMetadata = struct('RepetitionTime', 7, ...
                          'SliceTimingCorrected', false);

  [createdFiles, outFilesJson, initialMetadata] = setUp(sourceMetadata);

  updatedFiles = transferMetadataFromJson(createdFiles);

  assertEqual(updatedFiles, {outFilesJson});

  updatedMetadata = bids.util.jsondecode(outFilesJson);

  expectedMetadata = initialMetadata;
  expectedMetadata.RepetitionTime = 7;
  expectedMetadata.SliceTimingCorrected = false;

  assertEqual(updatedMetadata, expectedMetadata);

end

function test_transferMetadataFromJson_stc()

  sourceMetadata = struct('RepetitionTime', 7, ...
                          'SliceTimingCorrected', true, ...
                          'StartTime', 0.4);

  [createdFiles, outFilesJson, initialMetadata] = setUp(sourceMetadata);

  updatedFiles = transferMetadataFromJson(createdFiles);

  updatedMetadata = bids.util.jsondecode(outFilesJson);

  expectedMetadata = initialMetadata;
  expectedMetadata.RepetitionTime = 7;
  expectedMetadata.SliceTimingCorrected = true;
  expectedMetadata.StartTime = 0.4;

  assertEqual(updatedMetadata, expectedMetadata);

end

function test_transferMetadataFromJson_no_stc()

  sourceMetadata = struct('RepetitionTime', 7);

  [createdFiles, outFilesJson, initialMetadata] = setUp(sourceMetadata);

  updatedFiles = transferMetadataFromJson(createdFiles);

  updatedMetadata = bids.util.jsondecode(outFilesJson);

  expectedMetadata = initialMetadata;
  expectedMetadata.RepetitionTime = 7;
  expectedMetadata.SliceTimingCorrected = false;

  assertEqual(updatedMetadata, expectedMetadata);

end

function [createdFiles, outFilesJson, initialMetadata] = setUp(sourceMetadata)
  inFile = 'sub-01_task-foo_space-MNI_desc-preproc_bold.nii';
  outFile = 'sub-01_task-foo_space-MNI_desc-smth6_bold.nii';

  tmpPath = tempDir();
  folder = fullfile(tmpPath, 'sub-01', 'func');
  spm_mkdir(folder);

  sourceFile = fullfile(folder, inFile);
  bf = bids.File(sourceFile);
  bf.metadata_write(sourceMetadata);

  createdFiles = {fullfile(folder, outFile)};
  bf = bids.File(createdFiles{1});
  initialMetadata = struct('Sources', {{fullfile(folder, inFile)}});
  bf.metadata_write(initialMetadata);

  outFilesJson = fullfile(folder, bf.json_filename);
end
