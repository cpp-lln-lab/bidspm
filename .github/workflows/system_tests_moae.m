%
% (C) Copyright 2021 CPP_SPM developers

root_dir = getenv('GITHUB_WORKSPACE');

fprintf('\nroot dir is %s\n', root_dir);

addpath(fullfile(root_dir, 'spm12'));

cd(fullfile(root_dir, 'demos', 'MoAE'));

run test_moae;
