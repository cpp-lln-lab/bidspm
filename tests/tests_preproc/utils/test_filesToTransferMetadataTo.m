function test_suite = test_filesToTransferMetadataTo %#ok<*STOUT>
  % (C) Copyright 2023 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_filesToTransferMetadataTo_basic()

  folder = fullfile(filesep, 'foo', 'sub-01', 'func');

  batchOutput{5}.files = { ...
                          fullfile(folder, 'wumeanasub-01_task-foo_bold.nii,01'); ...
                          fullfile(folder, 'wuasub-01_task-foo_bold.nii,01'); ...
                          fullfile(folder, 'wuasub-01_task-foo_bold.nii,02') ...
                         };

  batchOutput{10}.rfiles = { ...
                            fullfile(folder, 'rsub-01_task-foo_bold.nii,01'); ...
                            fullfile(folder, 'rsub-01_task-foo_bold.nii,02'); ...
                            fullfile(folder, 'rsub-01_task-foo_bold.nii,03') ...
                           };

  batchToTransferMetadataTo = [5, 10];

  files = filesToTransferMetadataTo(batchOutput, batchToTransferMetadataTo);
  assertEqual(numel(files), numel(batchToTransferMetadataTo));
  assertEqual(files{1}, {fullfile(folder, 'wuasub-01_task-foo_bold.nii')});
  assertEqual(files{2}, {fullfile(folder, 'rsub-01_task-foo_bold.nii')});

end
