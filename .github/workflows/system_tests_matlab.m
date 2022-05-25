%
% (C) Copyright 2021 CPP_SPM developers

root_dir = getenv('GITHUB_WORKSPACE');

addpath(fullfile(root_dir, 'spm12'));

cd(root_dir);
cpp_spm('action', 'init');

cd(fullfile(root_dir, 'demos', 'MoAE'));
download_moae_ds(true);

cd(root_dir);
cpp_spm('action', 'uninit');

cd(fullfile(root_dir, 'manualTests'));

run test_moae;

% repeat this because test_moae has a "clear all"
root_dir = getenv('GITHUB_WORKSPACE');

cd(fullfile(root_dir, 'demos', 'face_repetition'));

run face_rep_resolution;
