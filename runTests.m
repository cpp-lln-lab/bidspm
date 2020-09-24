% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

warning('OFF');

addpath(fullfile(pwd, 'spm12'));
addpath(genpath(fullfile(pwd, 'src')));
addpath(genpath(fullfile(pwd, 'lib')));

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
