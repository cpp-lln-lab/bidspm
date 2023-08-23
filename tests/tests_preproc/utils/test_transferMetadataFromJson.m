function test_suite = test_transferMetadataFromJson %#ok<*STOUT>
  % (C) Copyright 2023 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_transferMetadataFromJson_raw_source()

  tmpPath = tempName();
  folder = fullfile(tmpPath, 'sub-01');

  inFile = 'sub-01_task-foo_bold.nii';
  spm_mkdir(fullfile(folder, 'func'));
  sourceFile = fullfile(folder, 'func', inFile);
  bf = bids.File(sourceFile);
  sourceMetadata = struct('RepetitionTime', 7);
  bf.metadata_write(sourceMetadata);

  outFile = 'sub-01_task-foo_space-individual_desc-stc_bold.nii';
  createdFiles = {fullfile(folder, 'func', outFile)};
  bf = bids.File(createdFiles{1});

  outMetadata = struct('Sources', {{}}, ...
                       'RawSources', {{fullfile('sub-01', ...
                                                'func', ...
                                                'sub-01_task-foo_bold.nii')}});
  bf.metadata_write(outMetadata);

  updatedFiles = transferMetadataFromJson(createdFiles);

  expectedMetadata = initialMetadata(createdFiles);
  expectedMetadata.RepetitionTime = 7;

  assertEqual(bids.util.jsondecode(updatedFiles{1}), expectedMetadata);

end

function test_transferMetadataFromJson_several_sources_with_todo()

  tmpPath = tempName();
  folder = fullfile(tmpPath, 'sub-01');

  inFile1 = 'sub-01_task-foo_space-individual_desc-preproc_bold.nii';
  spm_mkdir(fullfile(folder, 'func'));
  sourceFile = fullfile(folder, 'func', inFile1);
  bf = bids.File(sourceFile);
  sourceMetadata = struct('RepetitionTime', 7, ...
                          'SliceTimingCorrected', false);
  bf.metadata_write(sourceMetadata);

  outFile = 'sub-01_task-foo_space-MNI_desc-preproc_bold.nii';
  createdFiles = {fullfile(folder, 'func', outFile)};
  bf = bids.File(createdFiles{1});

  outMetadata = struct('Sources', {{fullfile('sub-01', 'func', inFile1), ...
                                    'TODO: add deformation field'}});
  bf.metadata_write(outMetadata);

  updatedFiles = transferMetadataFromJson(createdFiles);

  expectedMetadata = initialMetadata(createdFiles);
  expectedMetadata.RepetitionTime = 7;
  expectedMetadata.SliceTimingCorrected = false;

  assertEqual(bids.util.jsondecode(updatedFiles{1}), expectedMetadata);

end

function test_transferMetadataFromJson_several_sources()

  tmpPath = tempName();
  folder = fullfile(tmpPath, 'sub-01');

  inFile1 = 'sub-01_task-foo_space-individual_desc-preproc_bold.nii';
  spm_mkdir(fullfile(folder, 'func'));
  sourceFile = fullfile(folder, 'func', inFile1);
  bf = bids.File(sourceFile);
  sourceMetadata = struct('RepetitionTime', 7, ...
                          'SliceTimingCorrected', false);
  bf.metadata_write(sourceMetadata);

  inFile2 = 'sub-01_from-individual_to-MNI_xfm.nii';
  spm_mkdir(fullfile(folder, 'anat'));
  sourceFile = fullfile(folder, 'anat', inFile1);
  bf = bids.File(sourceFile);
  bf.metadata_write(struct());

  outFile = 'sub-01_task-foo_space-MNI_desc-preproc_bold.nii';
  createdFiles = {fullfile(folder, 'func', outFile)};
  bf = bids.File(createdFiles{1});

  outMetadata = struct('Sources', {{fullfile('sub-01', 'func', inFile1), ...
                                    fullfile('sub-01', 'anat', inFile2)}});
  bf.metadata_write(outMetadata);

  updatedFiles = transferMetadataFromJson(createdFiles);

  expectedMetadata = initialMetadata(createdFiles);
  expectedMetadata.RepetitionTime = 7;
  expectedMetadata.SliceTimingCorrected = false;

  assertEqual(bids.util.jsondecode(updatedFiles{1}), expectedMetadata);

end

function test_transferMetadataFromJson_basic()

  sourceMetadata = struct('RepetitionTime', 7, ...
                          'SliceTimingCorrected', false);

  createdFiles = setUp(sourceMetadata);

  updatedFiles = transferMetadataFromJson(createdFiles);

  assertEqual(exist(updatedFiles{1}, 'file'), 2);

  expectedMetadata = initialMetadata(createdFiles);
  expectedMetadata.RepetitionTime = 7;
  expectedMetadata.SliceTimingCorrected = false;

  assertEqual(bids.util.jsondecode(updatedFiles{1}), expectedMetadata);

end

function test_transferMetadataFromJson_no_RT()

  sourceMetadata = struct('SliceTimingCorrected', false);

  createdFiles = setUp(sourceMetadata);

  updatedFiles = transferMetadataFromJson(createdFiles);

  expectedMetadata = initialMetadata(createdFiles);
  expectedMetadata.SliceTimingCorrected = false;

  assertEqual(bids.util.jsondecode(updatedFiles{1}), expectedMetadata);

end

function test_transferMetadataFromJson_mean_image()

  sourceMetadata = struct('RepetitionTime', 7, ...
                          'SliceTimingCorrected', false);

  isMean = true;
  createdFiles = setUp(sourceMetadata, isMean);

  updatedFiles = transferMetadataFromJson(createdFiles);

  assert(isempty(updatedFiles));
end

function test_transferMetadataFromJson_with_TODO()

  sourceMetadata = struct('RepetitionTime', 7, ...
                          'SliceTimingCorrected', false);

  sourceToDo = true;
  isMean = false;
  createdFiles = setUp(sourceMetadata, ...
                       isMean, ...
                       sourceToDo);

  updatedFiles = transferMetadataFromJson(createdFiles);

  assert(isempty(updatedFiles));

end

function test_transferMetadataFromJson_with_extra_metadata()

  sourceMetadata = struct('RepetitionTime', 7);

  createdFiles = setUp(sourceMetadata);

  extraMetadata = struct('SliceTimingCorrected', true, ...
                         'StartTime', 0.4);

  updatedFiles = transferMetadataFromJson(createdFiles, extraMetadata);

  expectedMetadata = initialMetadata(createdFiles);
  expectedMetadata.RepetitionTime = 7;
  expectedMetadata.SliceTimingCorrected = true;
  expectedMetadata.StartTime = 0.4;

  assertEqual(bids.util.jsondecode(updatedFiles{1}), expectedMetadata);

end

function test_transferMetadataFromJson_with_stc()

  sourceMetadata = struct('RepetitionTime', 7, ...
                          'SliceTimingCorrected', true, ...
                          'StartTime', 0.4);

  createdFiles = setUp(sourceMetadata);

  updatedFiles = transferMetadataFromJson(createdFiles);

  expectedMetadata = initialMetadata(createdFiles);
  expectedMetadata.RepetitionTime = 7;
  expectedMetadata.SliceTimingCorrected = true;
  expectedMetadata.StartTime = 0.4;

  assertEqual(bids.util.jsondecode(updatedFiles{1}), expectedMetadata);

end

function test_transferMetadataFromJson_no_stc()

  sourceMetadata = struct('RepetitionTime', 7);

  createdFiles = setUp(sourceMetadata);

  updatedFiles = transferMetadataFromJson(createdFiles);

  expectedMetadata = initialMetadata(createdFiles);
  expectedMetadata.RepetitionTime = 7;
  expectedMetadata.SliceTimingCorrected = false;

  assertEqual(bids.util.jsondecode(updatedFiles{1}), expectedMetadata);

end

function createdFiles = setUp(inMetadata, isMean, sourceToDo)

  if nargin < 2
    isMean = false;
  end
  if nargin < 3
    sourceToDo = false;
  end

  inFile = 'sub-01_task-foo_space-MNI_desc-preproc_bold.nii';
  outFile = 'sub-01_task-foo_space-MNI_desc-smth6_bold.nii';
  if isMean
    outFile = 'sub-01_task-foo_space-MNI_desc-mean_bold.nii';
  end

  tmpPath = tempName();
  folder = fullfile(tmpPath, 'sub-01', 'func');
  spm_mkdir(folder);

  sourceFile = fullfile(folder, inFile);
  bf = bids.File(sourceFile);
  bf.metadata_write(inMetadata);

  createdFiles = {fullfile(folder, outFile)};
  bf = bids.File(createdFiles{1});

  outMetadata = struct('Sources', {{fullfile('sub-01', 'func', inFile)}});
  if sourceToDo
    outMetadata.Sources = 'TODO';
  end
  bf.metadata_write(outMetadata);

end

function value = initialMetadata(createdFiles)
  bf = bids.File(createdFiles{1});
  value = bf.metadata;
end
