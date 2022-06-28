function tests_octave()
  %
  % (C) Copyright 2021 CPP_SPM developers

  % Elapsed time is 284 seconds.

  more off;
  warning off;

  tic;

  cd(fullfile(fileparts(mfilename('fullpath')), '..', '..'));

  addpath(fullfile(pwd, 'tests', 'utils'));

  cpp_spm();

  if isGithubCi
    printToScreen('\nThis is github CI\n');
  else
    printToScreen('\nThis is not github CI\n');
  end

  printToScreen(sprintf('\nHome is %s\n', getenv('HOME')));

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
