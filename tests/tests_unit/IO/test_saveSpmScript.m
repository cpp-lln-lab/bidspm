function test_suite = test_saveSpmScript %#ok<*STOUT>
  % (C) Copyright 2022 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_saveSpmScript_basic()

  PWD = setUp();

  % GIVEN
  matlabbatch{1}.cfg_basicio.cfg_named_file.name = 'Anatomical';
  anatFile = fullfile('home', 'smith', 'raw', 'sub-01', 'anat', 'sub-01_T1w.nii');
  matlabbatch{1}.cfg_basicio.cfg_named_file.files = { {anatFile} };

  % WHEN
  outputFilename = saveSpmScript(matlabbatch);

  % THEN
  expectedFile = fullfile(pwd, returnBatchFileName('', '.m'));
  assertEqual(exist(expectedFile, 'file'), 2);

  expectedContent = fullfile(getTestDataDir(), 'dummy_batch.m');
  fid1 = fopen(expectedContent, 'r');
  expectedContent = fscanf(fid1, '%s');
  fclose(fid1);
  if ispc
    expectedContent = strrep('/', '\');
  end

  fid2 = fopen(outputFilename, 'r');
  actualContent = fscanf(fid2, '%s');
  fclose(fid2);

  assertEqual(actualContent, expectedContent);

  cd(PWD);

end

function test_saveSpmScript_output_name()

  PWD = setUp();

  % GIVEN
  matlabbatch{1}.cfg_basicio.cfg_named_file.name = 'Anatomical';
  anatFile = fullfile('home', 'smith', 'raw', 'sub-01', 'anat', 'sub-01_T1w.nii');
  matlabbatch{1}.cfg_basicio.cfg_named_file.files = { {anatFile} };

  % WHEN
  outputFilename = saveSpmScript(matlabbatch);

  % THEN
  expectedFile = fullfile(pwd, returnBatchFileName('', '.m'));
  assertEqual(exist(expectedFile, 'file'), 2);

  expectedContent = fullfile(getTestDataDir(), 'dummy_batch.m');
  compareContent(outputFilename, expectedFile);

  cd(PWD);

end

function test_saveSpmScript_from_file()

  % TODO add tests to overwrite output filename

  tmpDir = tempName();
  copyfile(fullfile(getTestDataDir(), 'mat_files'), tmpDir);

  % GIVEN
  inputMatFile = fullfile(tmpDir, 'dummy_batch.mat');

  % WHEN
  outputFilename = saveSpmScript(inputMatFile);

  % THEN
  expectedFile = fullfile(tmpDir, 'dummy_batch.m');
  assertEqual(exist(expectedFile, 'file'), 2);
  compareContent(outputFilename, expectedFile);

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

function PWD = setUp()
  PWD = pwd;
  tmpDir = tempName();
  cd(tmpDir);
  spm_mkdir cfg;
end
