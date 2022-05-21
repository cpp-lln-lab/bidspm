% This script runs preprocessing with different final spatial resolution in MNI space
% It then runs the subject level GLMs
%
% This can show how to script several analysis within the CPP_SPM framework
%
% (C) Copyright 2019 Remi Gau

clear;
clc;
close all;

downloadData = true;

addpath(fullfile(pwd, '..', '..'));
cpp_spm();

%% Set options

opt = face_rep_get_option_results();

%% Removes previous analysis, gets data and converts it to BIDS
if downloadData

  download_convert_face_rep_ds();

end

%% Run batches
reportBIDS(opt);

modelFile = opt.model.file;

for iResolution = 2:1:3

  opt.pipeline.name = ['cpp_spm-res' num2str(iResolution)];

  % set the final output resolution
  opt.funcVoxelDims = repmat(iResolution, 1, 3);

  opt.dir.preproc = spm_file( ...
                             fullfile(opt.dir.raw, ...
                                      '..', ...
                                      'derivatives', ...
                                      opt.pipeline.name), ...
                             'cpath');

  opt.dir.input = opt.dir.raw;

  %% create a new BIDS model json file
  % this way the GLM output will be store in a different directory for each
  % resolution as the name of the GLM directory is based on the name of the
  % model in the BIDS model
  content = spm_jsonread(opt.model.file);
  content.Name = [content.Name, ' resolution - ', num2str(iResolution)];

  bf = bids.File(modelFile);
  bf.entities.model = [bf.entities.model, ' resolution', num2str(iResolution)];

  newModel = spm_file(opt.model.file, 'filename', bf.filename);
  opt.model.file = newModel;

  bids.util.jsonencode(newModel, content);

  % run analysis
  bidsCopyInputFolder(opt);

  bidsSTC(opt);

  bidsSpatialPrepro(opt);

  bidsSmoothing(FWHM, opt);

  opt.pipeline.name = ['cpp_spm-stats-res' num2str(iResolution)];
  opt = checkOptions(opt);

  bidsFFX('specifyAndEstimate', opt);
  bidsFFX('contrasts', opt);

  % specify underlay image
  subLabel = '01';
  [BIDS, opt] = getData(opt, opt.dir.preproc);
  [~, anatDataDir] = getAnatFilename(BIDS, subLabel, opt);
  opt.results(1).montage.background = spm_select('FPList', ...
                                                             anatDataDir, ...
                                                             '^wm.*desc-skullstripped.*.nii$');

  bidsResults(opt);

end
