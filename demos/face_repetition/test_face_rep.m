% This script runs preprocessing with different final spatial resolution in MNI space
% It then runs the subject level GLMs
%
% This can show how to script several analysis within the CPP_SPM framework
%
% (C) Copyright 2019 Remi Gau

clear;
clc;
close all;

download_data = true;

WD = fileparts(mfilename('fullpath'));

addpath(fullfile(WD, '..', '..'));

if download_data
  cpp_spm();
  download_face_rep_ds(download_data);
end

model_file = fullfile(WD, 'models', 'model-faceRepetition_smdl.json');

for iResolution = 3 % :2:3

  opt.pipeline.name = ['cpp_spm-preproc-res' num2str(iResolution)];
  opt.funcVoxelDims = repmat(iResolution, 1, 3);

  %% preproc
  bids_dir = fullfile(WD, 'outputs', 'raw');
  output_dir = fullfile(WD, 'outputs', 'derivatives');

  preproc_dir = fullfile(output_dir, opt.pipeline.name);

  cpp_spm(bids_dir, output_dir, 'subject', ...
          'participant_label', {'01'}, ...
          'action', 'preprocess', ...
          'task', {'auditory'}, ...
          'space', {'IXI549Space'}, ...
          'options', opt);

  %% stats

  % create a new BIDS model json file
  %
  % this way the GLM output will be store in a different directory for each
  % resolution as the name of the GLM directory is based on the name of the
  % model in the BIDS model
  content = BidsModel(model_file);
  content.Name = [content.Name, ' resolution - ', num2str(iResolution)];

  newModel = spm_file(model_file, ...
                      'filename', ['model-faceRepetitionRes' num2str(iResolution) ' _smdl.json']);

  bids.util.jsonencode(newModel, content);

  % stats options
  opt.pipeline.name = ['cpp_spm-stats-res' num2str(iResolution)];

  % Specify the result to compute
  opt.results = defaultResultsStructure();
  opt.results.nodeName = 'run_level';

  opt.results.name = 'faces_gt_baseline_1';

  % Specify how you want your output (all the following are on false by default)
  opt.results.png = true();
  opt.results.csv = true();
  opt.results.threshSpm = true();
  opt.results.binary = true();
  opt.results.montage.do = true();
  opt.results.montage.slices = -26:3:6; % in mm
  opt.results.montage.orientation = 'axial';

  % specify underlay image
  BIDS = bids.layout(preproc_dir);
  anat = bids.query(BIDS, 'data', ...
                    'sub', '01', ...
                    'desc', 'skullstripped', ...
                    'suffix', 'T1w', ...
                    'space', 'IXI549Space');
  opt.results(1).montage.background = anat{1};

  results = defaultResultsStructure();
  results.nodeName = 'run_level';
  results.name = 'motion';
  results.png = true();

  opt.results(2) = results;

  cpp_spm(bids_dir, output_dir, 'subject', ...
          'participant_label', {'01'}, ...
          'action', 'stats', ...
          'preproc_dir', preproc_dir, ...
          'model_file', newModel, ...
          'options', opt);

end
