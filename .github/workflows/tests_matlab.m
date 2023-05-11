%
% (C) Copyright 2021 bidspm developers

root_dir = getenv('GITHUB_WORKSPACE');

if ~isempty(root_dir)
  addpath(fullfile(root_dir, 'spm12'));
  addpath(fullfile(root_dir, 'MOcov', 'MOcov'));

  cd(fullfile(root_dir, 'MOxUnit', 'MOxUnit'));
  run moxunit_set_path();
else
  root_dir = fullfile(fileparts(mfilename('fullpath')), '..', '..');
end
cd(root_dir);
bidspm('action', 'dev');

cd demos/MoAE;
download_moae_ds(true);

cd(root_dir);
success = bidspm('action', 'run_tests');

exit(double(~success));
