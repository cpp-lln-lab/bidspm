%
% (C) Copyright 2021 bidspm developers

root_dir = getenv('GITHUB_WORKSPACE');

addpath(fullfile(root_dir, 'spm12'));
addpath(fullfile(root_dir, 'MOcov', 'MOcov'));

cd(fullfile(root_dir, 'MOxUnit', 'MOxUnit'));
run moxunit_set_path();

cd(root_dir);
bidspm('action', 'dev');

cd demos/MoAE;
download_moae_ds(true);

cd(root_dir);
bidspm('action', 'run_tests');
