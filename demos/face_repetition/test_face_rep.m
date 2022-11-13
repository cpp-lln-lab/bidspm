% This script runs preprocessing with different final spatial resolution in MNI space
% It then runs the subject level GLMs
%
% This can show how to script several analysis within the bidspm framework
%
% (C) Copyright 2019 Remi Gau

clear;
clc;
close all;

% skipping validation for now
% as raw data is not 100% valid
skip_validation = true;

download_data = true;

WD = fileparts(mfilename('fullpath'));

addpath(fullfile(WD, '..', '..'));

bidspm();

if download_data
  download_face_rep_ds(download_data);
end

warning('off', 'SPM:noDisplay');
if isOctave
  warning('off', 'setGraphicWindow:noGraphicWindow');
end

optionsFile = fullfile(WD, 'options', 'options_task-facerepetition.json');

model_file = fullfile(WD, 'models', 'model-faceRepetition_smdl.json');

% skip unwarping with octave to avoid failure in CI
% see https://github.com/cpp-lln-lab/bidspm/issues/769
ignore = {''};
if isOctave
  ignore = {'unwarp'};
end

for iResolution = 2:3

  opt.pipeline.name = ['bidspm-res' num2str(iResolution)];
  opt.funcVoxelDims = repmat(iResolution, 1, 3);

  %% preproc
  bids_dir = fullfile(WD, 'outputs', 'raw');
  output_dir = fullfile(WD, 'outputs', 'derivatives');

  preproc_dir = fullfile(output_dir, opt.pipeline.name);

  bidspm(bids_dir, output_dir, 'subject', ...
         'participant_label', {'01'}, ...
         'action', 'preprocess', ...
         'task', {'facerepetition'}, ...
         'space', {'IXI549Space'}, ...
         'ignore', ignore, ...
         'options', opt, ...
         'skip_validation', skip_validation);

  %% stats

  % create a new BIDS model json file
  %
  % this way the GLM output will be store in a different directory for each
  % resolution as the name of the GLM directory is based on the name of the
  % model in the BIDS model
  content = bids.util.jsondecode(model_file);
  content.Name = [content.Name, ' resolution - ', num2str(iResolution)];

  newModel = spm_file(model_file, ...
                      'filename', ['model-faceRepetitionRes' num2str(iResolution) '_smdl.json']);

  bids.util.jsonencode(newModel, content);

  % stats options
  opt = bids.util.jsondecode(optionsFile);
  % TODO put in a json file
  opt.pipeline.name = ['bidspm-res' num2str(iResolution)];

  % specify underlay image
  BIDS = bids.layout([preproc_dir '-preproc'], 'use_schema', false);
  anat = bids.query(BIDS, 'data', ...
                    'sub', '01', ...
                    'suffix', 'T1w', ...
                    'space', 'IXI549Space');
  opt.results{1}.montage.background = anat{1};

  bidspm(bids_dir, output_dir, 'subject', ...
         'participant_label', {'01'}, ...
         'action', 'stats', ...
         'preproc_dir', [preproc_dir '-preproc'], ...
         'model_file', newModel, ...
         'options', opt, ...
         'skip_validation', skip_validation);

  % with Octave running more n-1 loop in CI is fine
  % but not running crashes with a segmentation fault
  % /home/runner/work/_temp/fb8e9d58-fa9f-4f93-8c96-387973f3632e.sh: line 2:
  % 7487 Segmentation fault      (core dumped) octave $OCTFLAGS --eval "run system_tests_facerep;"
  %
  % not sure why
  if isOctave
    break
  end

end
