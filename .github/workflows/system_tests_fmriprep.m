%
% (C) Copyright 2021 CPP_SPM developers

root_dir = getenv('GITHUB_WORKSPACE');

addpath(fullfile(root_dir, 'spm12'));

cd(fullfile(root_dir, 'demos', 'MoAE'));
system('make make inputs/fmriprep')
run moae_fmriprep;
