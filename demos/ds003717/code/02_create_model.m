% (C) Copyright 2022 Remi Gau

cwd = fileparts(mfilename('fullpath'));
addpath(fullfile(cwd, 'lib', 'bidspm'));
bidspm init;

bids_dir = fullfile(cwd, '..', 'inputs', 'ds003717');
output_dir = fullfile(cwd, '..', 'outputs');

bidspm(bids_dir, pwd, 'dataset', ...
       'action', 'default_model', ...
       'verbosity', 2, ...
       'space', {'IXI549Space'}, ...
       'task', {'SESS01'});
