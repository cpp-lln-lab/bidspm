function test_suite = test_saveSpmScript %#ok<*STOUT>
  %

  % (C) Copyright 2022 bidspm developers

  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end

  initTestSuite;

end

function test_saveSpmScript_basic()

  % GIVEN
  matlabbatch{1}.cfg_basicio.cfg_named_file.name = 'Anatomical';
  anatFile = fullfile('home', 'smith', 'raw', 'sub-01', 'anat', 'sub-01_T1w.nii');
  matlabbatch{1}.cfg_basicio.cfg_named_file.files = { {anatFile} };

  % WHEN
  outputFilename = saveSpmScript(matlabbatch);

  % THEN
  expectedFile = fullfile(pwd, returnBatchFileName('', '.m'));
  assertEqual(exist(expectedFile, 'file'), 2);

  expectedContent = fullfile(getDummyDataDir(), 'dummy_batch.m');
  fid1 = fopen(expectedContent, 'r');
  expectedContent = fscanf(fid1, '%s');
  fclose(fid1);

  fid2 = fopen(outputFilename, 'r');
  actualContent = fscanf(fid2, '%s');
  fclose(fid2);

  assertEqual(actualContent, expectedContent);

  cleanUp();

end

function test_saveSpmScript_output_name()

  % GIVEN
  matlabbatch{1}.cfg_basicio.cfg_named_file.name = 'Anatomical';
  anatFile = fullfile('home', 'smith', 'raw', 'sub-01', 'anat', 'sub-01_T1w.nii');
  matlabbatch{1}.cfg_basicio.cfg_named_file.files = { {anatFile} };

  % WHEN
  outputFilename = saveSpmScript(matlabbatch);

  % THEN
  expectedFile = fullfile(pwd, returnBatchFileName('', '.m'));
  assertEqual(exist(expectedFile, 'file'), 2);

  expectedContent = fullfile(getDummyDataDir(), 'dummy_batch.m');
  compareContent(outputFilename, expectedFile);

  cleanUp();

end

function test_saveSpmScript_from_file()

  % TODO add tests to overwrite output filename

  % GIVEN
  inputMatFile = fullfile(getDummyDataDir(), 'mat_files', 'dummy_batch.mat');

  % WHEN
  outputFilename = saveSpmScript(inputMatFile);

  % THEN
  expectedFile = fullfile(getDummyDataDir(), 'mat_files', 'dummy_batch.m');
  assertEqual(exist(expectedFile, 'file'), 2);

  expectedFile = fullfile(getDummyDataDir(), 'dummy_batch.m');
  compareContent(outputFilename, expectedFile);

  cleanUp();

end

function compareContent(actualFile, expectedFile)

  fid1 = fopen(expectedFile, 'r');
  expectedContent = fscanf(fid1, '%s');
  fclose(fid1);

  fid2 = fopen(actualFile, 'r');
  actualContent = fscanf(fid2, '%s');
  fclose(fid2);

  assertEqual(actualContent, expectedContent);

end

function setUp()

end

function cleanUp()

  delete batch*.m;
  delete(fullfile(getDummyDataDir(), 'mat_files', 'dummy_batch.m'));

end
