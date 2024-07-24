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

bidspm();
if download_data
  download_moae_ds(download_data, clean); %#ok<*UNRCH>
end

warning('off', 'SPM:noDisplay');

optionsFile = fullfile(WD, 'options', 'options_task-auditory.json');

space = {
         'IXI549Space'
         'individual'
         'IXI549Space'
         'individual'};
ignore = {{'unwarp', 'qa'}
          {'unwarp'}
          {''}
          {''}};
models = {
          fullfile(WD, 'models', 'model-MoAE_smdl.json')
          fullfile(WD, 'models', 'model-MoAEindividual_smdl.json')
          fullfile(WD, 'models', 'model-MoAE_smdl.json')
          fullfile(WD, 'models', 'model-MoAEindividual_smdl.json')};

for iOption = 1:numel(space)

  fprintf(1, repmat('\n', 1, 5));

  %% preproc
  bids_dir = fullfile(WD, 'inputs', 'raw');
  output_dir = fullfile(tempname, 'outputs', 'derivatives');
  spm_mkdir(output_dir);

  bidspm(bids_dir, output_dir, 'subject', ...
         'participant_label', {'01'}, ...
         'action', 'preprocess', ...
         'task', 'auditory', ...
         'ignore', ignore{iOption}, ...
         'space', space(iOption), ...
         'options', optionsFile);

  %% stats
  preproc_dir = fullfile(output_dir, 'bidspm-preproc');

  if ~bids.internal.is_octave() && ~ispc()
    % only specify the subject level model
    bidspm(bids_dir, output_dir, 'subject', ...
           'participant_label', {'01'}, ...
           'action', 'stats', ...
           'preproc_dir', preproc_dir, ...
           'model_file', models{iOption}, ...
           'options', optionsFile, ...
           'design_only', true);
  end

  % specify, estimate model and contrasts, and view results
  bidspm(bids_dir, output_dir, 'subject', ...
         'participant_label', {'01'}, ...
         'action', 'stats', ...
         'preproc_dir', preproc_dir, ...
         'model_file', models{iOption}, ...
         'options', optionsFile);

  cd(WD);

  % Octave
  % running more n-1 loop in CI is fine
  % but not running crashes with a segmentation fault
  % /home/runner/work/_temp/fb8e9d58-fa9f-4f93-8c96-387973f3632e.sh: line 2:
  % 7487 Segmentation fault      (core dumped) octave $OCTFLAGS --eval "run system_tests_facerep;"
  %
  % not sure why
  %

  % Windows
  % Error using overwriteDir
  %    C:\Users\runneradmin\AppData\Local\Temp\8f7c44ca98d0\outputs\derivatives\bidspm-stats\
  %           sub-01\task-auditory_space-individual_FWHM-6 could not be removed.
  % Error in setBatchSubjectLevelGLMSpec (line 73)
  %    overwriteDir(ffxDir, opt);
  if bids.internal.is_octave() || ispc()
    break
  end

end
