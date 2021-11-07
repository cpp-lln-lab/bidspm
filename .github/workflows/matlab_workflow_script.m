
root_dir = getenv('GITHUB_WORKSPACE');

addpath(fullfile(root_dir, 'spm12'));
addpath(fullfile(root_dir, 'MOcov', 'MOcov'));
addpath(fullfile(root_dir, 'cpp_spm'));

cd(fullfile(root_dir, 'MOxUnit', 'MOxUnit'));
run moxunit_set_path(); 

cd(fullfile(root_dir, 'CPP_SPM'));
initCppSpm()
run run_tests()