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

participant_label = {'[0-9]*'}; %#ok<*NASGU>
if TESTING
  participant_label = {'^0[12]$'};
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

mutliverse.strategy = {'motion', 'wm_csf', 'scrub', 'non_steady_state'};
mutliverse.motion = {'none', 'basic', 'full'};
mutliverse.scrub = [false, true];
mutliverse.wm_csf = {'none', 'basic', 'full'};
mutliverse.non_steady_state = [false, true];

if TESTING
  mutliverse.strategy = {'motion', 'wm_csf', 'scrub', 'non_steady_state'};
  mutliverse.motion = {'none', 'basic'};
  mutliverse.scrub = [false, true];
  mutliverse.wm_csf = {'none'};
  mutliverse.non_steady_state = false;
end

create_model_families(models_dir, default_model_file, mutliverse);

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
function create_model_families(models_dir, default_model_file, mutliverse)
  % create models from a default one
  %

  % TODO incorporate into bidspm

  % TODO add support for 12 motion regressors
  strategyToSkip = fieldnames(mutliverse);
  idxStrategyToSkip = ~ismember(fieldnames(mutliverse), mutliverse.strategy);
  strategyToSkip = strategyToSkip(idxStrategyToSkip);
  for i = 1:numel(strategyToSkip)
    mutliverse.(strategyToSkip{i}) = {''};
  end

  for i = 1:numel(mutliverse.motion)
    for j = 1:numel(mutliverse.scrub)
      for k = 1:numel(mutliverse.wm_csf)
        for l = 1:numel(mutliverse.non_steady_state)

          model = bids.util.jsondecode(default_model_file);

          name = sprintf('rp-%s_scrub-%i_tissue-%s_nsso-%i', ...
                         mutliverse.motion{i}, ...
                         mutliverse.scrub(j), ...
                         mutliverse.wm_csf{k}, ...
                         mutliverse.non_steady_state(l));
          model.Name = name;
          model.Nodes.Name = name;

          design_matrix = model.Nodes.Model.X;

          switch mutliverse.motion{i}
            case 'none'
            case 'basic'
              design_matrix{end + 1} = 'rot_?';
              design_matrix{end + 1} = 'trans_?';
            case 12
            case 'full'
              design_matrix{end + 1} = 'rot_*';
              design_matrix{end + 1} = 'trans_*';
          end

          if mutliverse.scrub(j) == 1
            design_matrix{end + 1} = 'motion_outlier*'; %#ok<*AGROW>
          end

          switch mutliverse.wm_csf{k}
            case 'none'
            case 'basic'
              design_matrix{end + 1} = 'csf';
              design_matrix{end + 1} = 'white';
            case 'full'
              design_matrix{end + 1} = 'csf_*';
              design_matrix{end + 1} = 'white_*';
          end

          if mutliverse.non_steady_state(l)
            design_matrix{end + 1} = 'non_steady_state_outlier*';
          end

          model.Nodes.Model.X = design_matrix;

          output_file = fullfile(models_dir, ['model_' name '_smdl.json']);
          bids.util.jsonencode(output_file, model);
        end
      end
    end
  end
end
