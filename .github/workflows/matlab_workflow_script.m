pwd

getenv('GITHUB_WORKSPACE')

ls

addpath(fullfile(pwd, 'spm12'))
addpath(fullfile(pwd, 'MOcov', 'MOcov'));
addpath(fullfile(pwd, 'cpp_spm'))

addpath(getenv('GITHUB_WORKSPACE'));

run MOxUnit/MOxUnit/moxunit_set_path(); 

initCppSpm()
run_tests