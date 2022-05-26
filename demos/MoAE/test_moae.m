% Script to run to check that the whole pipeline works fine
% with different options encoded in json files
%
% - default options (that is realign & unwarp + space = MNI)
% - indidivual space
% - realign only
% - indidivual space + realign only
%
% Rudimentary attempt of a "system-level" "smoke-test" of the "happy path"...
%
%
% (C) Copyright 2019 Remi Gau

clear;
clc;
close all;

download_data = true;
clean = true;

WD = fileparts(mfilename('fullpath'));

addpath(fullfile(WD, '..', '..'));

if download_data
  cpp_spm();
  download_moae_ds(download_data, clean);
end

optionsFile = fullfile(WD, 'options', 'options_task-auditory.json');

space = { 'IXI549Space'
         'IXI549Space'
         'individual'
         'individual'};
ignore = {
          {''}
          {'unwarp'}
          {'unwarp'}
          {''}
         };

models = {
          fullfile(WD, 'models', 'model-MoAE_smdl.json')
          fullfile(WD, 'models', 'model-MoAE_smdl.json')
          fullfile(WD, 'models', 'model-MoAEindividual_smdl.json')
          fullfile(WD, 'models', 'model-MoAEindividual_smdl.json')
         };

for iOption = 1:numel(space)

  fprintf(1, repmat('\n', 1, 5));

  %% preproc
  bids_dir = fullfile(WD, 'inputs', 'raw');
  output_dir = fullfile(WD, 'outputs', 'derivatives');

  cpp_spm(bids_dir, output_dir, 'subject', ...
          'participant_label', {'01'}, ...
          'action', 'preprocess', ...
          'task', {'auditory'}, ...
          'ignore', ignore{iOption}, ...
          'space', space(iOption), ...
          'options', optionsFile);

  %% stats
  preproc_dir = fullfile(output_dir, 'cpp_spm-preproc');

  cpp_spm(bids_dir, output_dir, 'subject', ...
          'participant_label', {'01'}, ...
          'action', 'stats', ...
          'preproc_dir', preproc_dir, ...
          'model_file', models{iOption}, ...
          'options', optionsFile);

  cd(WD);

  rmdir(fullfile(WD, 'outputs', 'derivatives'), 's');

end
