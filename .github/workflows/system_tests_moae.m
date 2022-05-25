%
% (C) Copyright 2021 CPP_SPM developers

root_dir = getenv('GITHUB_WORKSPACE');

addpath(fullfile(root_dir, 'spm12'));

cd(root_dir);
initCppSpm;

cd(fullfile(root_dir, 'demos', 'MoAE'));
download_moae_ds(true);

cd(fullfile(root_dir, 'manualTests'));
run test_moae;
