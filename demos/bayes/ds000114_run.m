% (C) Copyright 2023 bidspm developers

clear;
clc;

addpath(fullfile(pwd, '..', '..'));
bidspm();

% set to false to not re run the smoothing
SMOOTH = true;

% set to false to not re run the model specification
FIRST_LEVEL = true;

VERBOSITY = 1;

FWHM = 8;

% to run on fewer subjects
TESTING = true;

% The directory where the data are located
root_dir = fileparts(mfilename('fullpath'));
bids_dir = fullfile(root_dir, 'inputs', 'ds000114');
fmriprep_dir = fullfile(root_dir, 'inputs', 'ds000114-fmriprep');
output_dir = fullfile(root_dir, 'outputs', 'ds000114', 'derivatives');

models_dir = fullfile(root_dir, 'models');

participant_label = {'[0-9]*'};
if TESTING
  participant_label = {'^0[123]$'};
end

%% Smooth
if SMOOTH
  % only need to smooth the functional data
  opt.query.modality = {'func'};
  bidspm(fmriprep_dir, output_dir, 'subject', ...
         'action', 'smooth', ...
         'participant_label', participant_label, ...
         'task', {'overtverbgeneration'}, ...
         'space', {'MNI152NLin2009cAsym'}, ...
         'fwhm', FWHM, ...
         'verbosity', VERBOSITY, ...
         'options', opt); %#ok<*UNRCH>
end

%% create models from a default one

default_model_file = fullfile(models_dir, 'default_model.json');
% FIXME: crashes with 0 real param
nb_realignment_param = [0, 6, 24];
scrubbing = [0, 1];

create_model_families(models_dir, default_model_file, nb_realignment_param, scrubbing);

%% Statistics
preproc_dir = fullfile(output_dir, 'bidspm-preproc');

%% Subject level analysis
if FIRST_LEVEL

  bidspm(bids_dir, output_dir, 'subject', ...
         'participant_label', participant_label, ...
         'action', 'specify_only', ...
         'preproc_dir', preproc_dir, ...
         'model_file', models_dir, ...
         'fwhm', FWHM, ...
         'skip_validation', true, ...
         'use_dummy_regressor', true, ...
         'verbosity', VERBOSITY);

end

bidspm(bids_dir, output_dir, 'subject', ...
       'action', 'bms', ...
       'participant_label', participant_label, ...
       'models_dir', models_dir, ...
       'fwhm', FWHM, ...
       'skip_validation', true, ...
       'verbosity', VERBOSITY);

%%
function create_model_families(models_dir, default_model_file, nb_realignment_param, scrubbing)
  % create models from a default one
  %

  for i = 1:numel(nb_realignment_param)
    for j = 1:numel(scrubbing)

      model = bids.util.jsondecode(default_model_file);

      name = sprintf('rp-%i_scrub-%i', ...
                     nb_realignment_param(i), ...
                     scrubbing(j));
      model.Name = name;
      model.Nodes.Name = name;

      design_matrix = model.Nodes.Model.X;
      if scrubbing(j) == 1
        design_matrix{end + 1} = '*outlier*'; %#ok<*AGROW>
      end
      switch nb_realignment_param(i)
        case 0
        case 6
          design_matrix{end + 1} = 'rot_?';
          design_matrix{end + 1} = 'trans_?';
        case 24
          design_matrix{end + 1} = 'rot_*';
          design_matrix{end + 1} = 'trans_*';
      end
      model.Nodes.Model.X = design_matrix;

      output_file = fullfile(models_dir, ['model_' name '_smdl.json']);
      bids.util.jsonencode(output_file, model);
    end
  end
end
