%
% (C) Copyright 2021 CPP_SPM developers

root_dir = getenv('GITHUB_WORKSPACE');

addpath(fullfile(root_dir, 'spm12'));

% TODO replace with a data set from open neuro
cd(fullfile(root_dir, 'demos', 'MoAE'));
system('make inputs/fmriprep');
run moae_fmriprep;
