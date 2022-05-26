% This script runs preprocessing with different final spatial resolution in MNI space
% It then runs the subject level GLMs
%
% This can show how to script several analysis within the CPP_SPM framework
%
% (C) Copyright 2019 Remi Gau

clear;
clc;
close all;

download_data = false;

WD = fileparts(mfilename('fullpath'));

addpath(fullfile(WD, '..', '..'));

if download_data
  cpp_spm();
  download_face_rep_ds(download_data);
end

optionsFile = fullfile(WD, 'options', 'options_task-facerepetition.json');

model_file = fullfile(WD, 'models', 'model-faceRepetition_smdl.json');

for iResolution = 2:3

  opt.pipeline.name = ['cpp_spm-res' num2str(iResolution)];
  opt.funcVoxelDims = repmat(iResolution, 1, 3);

  %% preproc
  bids_dir = fullfile(WD, 'outputs', 'raw');
  output_dir = fullfile(WD, 'outputs', 'derivatives');

  preproc_dir = fullfile(output_dir, opt.pipeline.name);

  cpp_spm(bids_dir, output_dir, 'subject', ...
          'participant_label', {'01'}, ...
          'action', 'preprocess', ...
          'task', {'facerepetition'}, ...
          'space', {'IXI549Space'}, ...
          'options', opt);

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
  opt.pipeline.name = ['cpp_spm-res' num2str(iResolution)];

  % specify underlay image
  BIDS = bids.layout([preproc_dir '-preproc'], 'use_schema', false);
  anat = bids.query(BIDS, 'data', ...
                    'sub', '01', ...
                    'suffix', 'T1w', ...
                    'space', 'IXI549Space');
  opt.results{1}.montage.background = anat{1};

  cpp_spm(bids_dir, output_dir, 'subject', ...
          'participant_label', {'01'}, ...
          'action', 'stats', ...
          'preproc_dir', [preproc_dir '-preproc'], ...
          'model_file', newModel, ...
          'options', opt);

end
