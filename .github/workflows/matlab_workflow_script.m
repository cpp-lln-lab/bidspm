
root_dir = getenv('GITHUB_WORKSPACE');

disp(root_dir)

ls

addpath(fullfile(root_dir, 'spm12'));
addpath(fullfile(root_dir, 'MOcov', 'MOcov'));

cd(fullfile(root_dir, 'MOxUnit', 'MOxUnit'));
run moxunit_set_path(); 

cd(fullfile(root_dir));
initCppSpm()
run run_tests()