%
% (C) Copyright 2021 CPP_SPM developers

root_dir = getenv('GITHUB_WORKSPACE');

addpath(fullfile(root_dir, 'spm12'));
addpath(fullfile(root_dir, 'MOcov', 'MOcov'));

cd(fullfile(root_dir, 'MOxUnit', 'MOxUnit'));
run moxunit_set_path();

cd(root_dir);
initCppSpm();
addpath(fullfile(root_dir, 'tests', 'utils'));

cd demos/MoAE;
download_moae_ds(true);

cd(root_dir);
run run_tests();
