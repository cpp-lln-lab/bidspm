% (C) Copyright 2022 bidspm developers

function test_suite = test_renamePng %#ok<*STOUT>
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_renamePng_basic()

  outputDir = tempName();

  touch(fullfile(outputDir, 'sub-foo_designmatrix_001.png'));
  touch(fullfile(outputDir, 'sub-foo_designmatrix_002.png'));

  files = dir(fullfile(outputDir, 'sub*_00*.png'));
  assertEqual(numel(files), 2);

  renamePng(outputDir);

  files = dir(fullfile(outputDir, 'sub*_00*.png'));
  assertEqual(numel(files), 0);

  files = dir(fullfile(outputDir, 'sub*_designmatrix.png'));
  assertEqual(numel(files), 1);

end
