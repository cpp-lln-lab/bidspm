%
% (C) Copyright 2021 CPP_SPM developers

root_dir = getenv('GITHUB_WORKSPACE');

addpath(fullfile(root_dir, 'spm12'));
addpath(fullfile(root_dir, 'MOcov', 'MOcov'));
addpath(fullfile(root_dir, 'tests', 'utils'));

cd(fullfile(root_dir, 'MOxUnit', 'MOxUnit'));
run moxunit_set_path();

cd(fullfile(root_dir));
initCppSpm();
run run_tests();
