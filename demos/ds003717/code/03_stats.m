% (C) Copyright 2022 Remi Gau

cwd = fileparts(mfilename('fullpath'));
addpath(fullfile(cwd, 'lib', 'bidspm'));
bidspm init;

bids_dir = fullfile(cwd, '..', 'inputs', 'ds003717');
output_dir = fullfile(cwd, '..', 'outputs');

%%
participants = {'01', '02'};

preproc_dir = fullfile(output_dir, 'derivatives', 'bidspm-preproc');

% You can try some of the other models from the models folder.
model_file = fullfile(cwd, 'models', 'model-defaultSESS01_smdl.json');

% definte what result to see
opt.results(1) = defaultResultsStructure();
opt.results(1).nodeName = 'run_combine_AV';
opt.results(1).name = 'AV';
opt.results(1).MC =  'none';
opt.results(1).p = 0.01;
opt.results(1).k = 0;
opt.results(1).png = true;
opt.results(1).binary = true;
opt.results(1).csv = true;
opt.results(1).atlas = 'aal';
opt.results(1).montage.slices = -0:2:16;
opt.results(1).montage.do = true;

bidspm(bids_dir, output_dir, 'subject', ...
       'action', 'stats', ...
       'preproc_dir', preproc_dir, ...
       'model_file', model_file, ...
       'participant_label', participants, ...
       'verbosity', 2, ...
       'roi_based', false, ...
       'design_only', false, ...
       'concatenate', false, ...
       'fwhm', 6, ...
       'skip_validation', true, ...
       'options', opt);
