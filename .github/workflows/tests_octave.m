%
% (C) Copyright 2021 CPP_SPM developers

root_dir = getenv('GITHUB_WORKSPACE');

cd(root_dir);
cpp_spm('action', 'dev');

cd demos/MoAE;
download_moae_ds(true);

cd(root_dir);
run run_tests();
