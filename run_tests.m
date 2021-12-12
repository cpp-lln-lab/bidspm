% (C) Copyright 2019 CPP_SPM developers

% Elapsed time is 284 seconds.

tic;

initCppSpm();

if isGithubCi
  fprintf(1, '\nThis is github CI\n');
else
  fprintf(1, '\nThis is not github CI\n');
end

fprintf('\nHome is %s\n', getenv('HOME'));

warning('OFF');

spm('defaults', 'fMRI');

folderToCover = fullfile(pwd, 'src');
testFolder = fullfile(pwd, 'tests');

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
