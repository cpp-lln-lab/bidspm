function tests_octave()
  %

  % (C) Copyright 2021 bidspm developers

  % Elapsed time is 284 seconds.

  more off;
  warning off;

  tic;

  cd(fullfile(fileparts(mfilename('fullpath')), '..', '..'));

  addpath(fullfile(pwd, 'tests', 'utils'));

  bidspm();

  if isGithubCi
    printToScreen('This is github CI');
  else
    printToScreen('This is not github CI');
  end

  printToScreen(sprintf('Home is %s', getenv('HOME')));

  spm('defaults', 'fMRI');

  subfolder = '';

  folderToCover = fullfile(pwd, 'src');
  testFolder = fullfile(pwd, 'tests', subfolder);

  success = moxunit_runtests( ...
                             testFolder, ...
                             '-verbose', '-recursive', '-with_coverage', ...
                             '-cover', folderToCover, ...
                             '-cover_xml_file', 'coverage.xml', ...
                             '-cover_html_dir', fullfile(pwd, 'coverage_html'));

  if success
    system('echo 0 > test_report.log');
  else
    system('echo 1 > test_report.log');
  end

  toc;

end
