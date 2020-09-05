warning('OFF');

addpath(fullfile(pwd, '..', 'spm12'));

spm('defaults', 'fMRI');

success = moxunit_runtests( ...
    pwd, ...
    '-verbose', '-recursive', '-with_coverage', ...
    '-cover', fullfile('..', 'subfun'), ...
    '-cover_xml_file', 'coverage.xml', ...
    '-cover_html_dir', fullfile(pwd, 'coverage_html'));

if success
    system('echo 0 > test_report.log');
else
    system('echo 1 > test_report.log');
end
