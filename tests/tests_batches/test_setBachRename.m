function test_suite = test_setBachRename %#ok<*STOUT>
  %
  % (C) Copyright 2022 CPP_SPM developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_setBachRename_basic()

  % GIVEN
  filename = 'sub-01_T1w_seg8.mat';
  setUp(filename);

  files = {fullfile(pwd, filename)};
  moveTo = {pwd};
  patternReplace(1).pattern = 'T1w';
  patternReplace(1).repl = 'label-T1w';
  patternReplace(2).pattern = 'seg8';
  patternReplace(2).repl = 'segparam';

  % WHEN
  matlabbatch = {};
  matlabbatch = setBachRename(matlabbatch, files, moveTo, patternReplace);

  spm_jobman('run', matlabbatch);

  % THEN
  expectedFile = 'sub-01_label-T1w_segparam.mat';
  assert(exist(fullfile(pwd, expectedFile), 'file') == 2);

  cleanUp(expectedFile);

end

function setUp(filename)

  system(sprintf('touch %s', filename));

end

function cleanUp(filename)

  delete(fullfile(pwd, filename));

end
