% (C) Copyright 2019 Remi Gau
%
%
% runs preprocessing with different final spatial resolution in MNI space
%

clear;
clc;
close all;

FWHM = 6;

downloadData = true;

run ../../initCppSpm.m;

%% Set options

opt = face_rep_get_option_results();

%% Removes previous analysis, gets data and converts it to BIDS
if downloadData

  dowload_convert_face_rep_ds();

end

%% Run batches

reportBIDS(opt);

modelFile = opt.model.file;

for iResolution = 1:0.5:3

  opt.funcVoxelDims = repmat(iResolution, 1, 3);

  opt.derivativesDir = spm_file( ...
                                fullfile(opt.dataDir, ...
                                         '..', ...
                                         'derivatives', ...
                                         ['cpp_spm-res' num2str(iResolution)]), 'cpath');

  content = spm_jsonread(opt.model.file);
  content.Name = [content.Name, ' resolution - ', num2str(iResolution)];

  p = bids.internal.parse_filename(modelFile);
  p.model = [p.model, ' resolution', num2str(iResolution)];
  newModel = spm_file(opt.model.file, 'filename', createFilename(p));
  opt.model.file = newModel;

  spm_jsonwrite(newModel, content, struct('indent', '   '));

  bidsCopyRawFolder(opt, 1);

  bidsSTC(opt);

  bidsSpatialPrepro(opt);

  bidsSmoothing(FWHM, opt);

  bidsFFX('specifyAndEstimate', opt, FWHM);
  bidsFFX('contrasts', opt, FWHM);

  % specify underlay image
  subLabel = '01';
  [BIDS, opt] = getData(opt);
  [~, anatDataDir] = getAnatFilename(BIDS, subLabel, opt);
  opt.result.Steps(1).Output.montage.background = spm_select('FPList', ...
                                                             anatDataDir, ...
                                                             '^wm.*.nii$');

  bidsResults(opt, FWHM);

end
