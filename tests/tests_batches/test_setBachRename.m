function test_suite = test_setBachRename %#ok<*STOUT>
  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_setBachRename_basic()

  % GIVEN
  moveTo = tempName();
  files = fullfile(moveTo, 'sub-01_T1w_seg8.mat');
  touch(files);

  patternReplace(1).pattern = 'T1w';
  patternReplace(1).repl = 'label-T1w';
  patternReplace(2).pattern = 'seg8';
  patternReplace(2).repl = 'segparam';

  % WHEN
  matlabbatch = {};
  matlabbatch = setBachRename(matlabbatch, {files}, {moveTo}, patternReplace);

  spm_jobman('run', matlabbatch);

  % THEN
  expectedFile = 'sub-01_label-T1w_segparam.mat';
  assert(exist(fullfile(moveTo, expectedFile), 'file') == 2);

end
