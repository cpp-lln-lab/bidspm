function test_suite = test_renamePngCsvResults %#ok<*STOUT>
  % (C) Copyright 2023 bidspm developers
  try % assignment of 'localfunctions' is necessary in Matlab >= 2016
    test_functions = localfunctions(); %#ok<*NASGU>
  catch % no problem; early Matlab versions can use initTestSuite fine
  end
  initTestSuite;
end

function test_renamePngCsvResults_basic()

  glmDir = setup();

  opt = struct('taskName', {{'MGT'}});

  subLabel = '01';

  result = struct('MC', 'FWE', ...
                  'atlas', 'Neuromorphometrics', ...
                  'binary', 0, ...
                  'csv', 1, ...
                  'k', 0, ...
                  'name', 'cash_demean_3', ...
                  'nidm', 1, ...
                  'nodeName', 'run_level', ...
                  'p', 0.0500, ...
                  'png', 1, ...
                  'threshSpm', 0, ...
                  'useMask', 0, ...
                  'space', {{'MNI152NLin2009cAsym'}}, ...
                  'dir', glmDir);

  renamePngCsvResults(opt, result, '.png', subLabel);

  renamedFile =  ['sub-01_task-MGT_space-MNI152NLin2009cAsym', ...
                  '_desc-cashDemean3_p-0pt050_k-0_MC-FWE_page-001_results.png'];
  assertEqual(exist(fullfile(glmDir, renamedFile), 'file'), 2);
  renamedFile =  ['sub-01_task-MGT_space-MNI152NLin2009cAsym', ...
                  '_desc-cashDemean3_p-0pt050_k-0_MC-FWE_page-002_results.png'];
  assertEqual(exist(fullfile(glmDir, renamedFile), 'file'), 2);

end

function test_renamePngCsvResults_group()

  glmDir = setup();

  opt = struct('taskName', {{'MGT'}});

  result = struct('MC', 'FWE', ...
                  'atlas', 'Neuromorphometrics', ...
                  'binary', 0, ...
                  'csv', 1, ...
                  'k', 0, ...
                  'name', 'cash_demean_3', ...
                  'nidm', 1, ...
                  'nodeName', 'run_level', ...
                  'p', 0.0500, ...
                  'png', 1, ...
                  'threshSpm', 0, ...
                  'useMask', 0, ...
                  'space', {{'MNI152NLin2009cAsym'}}, ...
                  'dir', glmDir);

  renamePngCsvResults(opt, result, '.png');

  renamedFile =  ['task-MGT_space-MNI152NLin2009cAsym', ...
                  '_desc-cashDemean3_p-0pt050_k-0_MC-FWE_page-001_results.png'];
  assertEqual(exist(fullfile(glmDir, renamedFile), 'file'), 2);
  renamedFile =  ['task-MGT_space-MNI152NLin2009cAsym', ...
                  '_desc-cashDemean3_p-0pt050_k-0_MC-FWE_page-002_results.png'];
  assertEqual(exist(fullfile(glmDir, renamedFile), 'file'), 2);

end

function glmDir = setup()
  glmDir = tempname();
  spm_mkdir(glmDir);
  files = { 'spm_2023Jul31_001.png',  'spm_2023Jul31_002.png'};
  for i = 1:numel(files)
    fid = fopen(fullfile(glmDir, files{i}), 'w');
    fclose(fid);
  end
end
