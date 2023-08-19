function test_suite = test_transferMetadata %#ok<*STOUT>
  % (C) Copyright 2023 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_transferMetadata_basic()

  folder = fullfile(filesep, 'foo', 'sub-01', 'func');

  subIdx = 1;
  unRenamedFiles{subIdx}{1} = {fullfile(folder, 'wuasub-01_task-foo_bold.nii')};
  unRenamedFiles{subIdx}{2} = {fullfile(folder, 'rsub-01_task-foo_bold.nii')};

  opt.subjects = {'01'};

  srcMetadata = struct('RepetitionTime', 7, ...
                       'SliceTimingCorrected', false);

  createdFiles = {
                  'sub-01_task-foo_space-MNI_desc-preproc_bold.nii'
                  'sub-01_task-foo_space-T1w_desc-preproc_bold.nii'
                 };

  tmpPath = tempDir();
  for i = 1:numel(createdFiles)
    createdFiles{i} = fullfile(tmpPath, createdFiles{i});
    jsonFile = spm_file(createdFiles{i}, 'ext', '.json');
    bids.util.jsonencode(jsonFile, struct('SpmFilename', unRenamedFiles{subIdx}{i}));
  end

  transferMetadata(opt, createdFiles, unRenamedFiles, srcMetadata);

  for i = 1:numel(createdFiles)
    jsonFile = spm_file(createdFiles{i}, 'ext', '.json');
    metadata = bids.util.jsondecode(jsonFile);
    assertEqual(metadata.RepetitionTime, 7);
  end
end
