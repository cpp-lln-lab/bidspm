% (C) Copyright 2019 Remi Gau

% adapted from face_rep_fun
%
% runs preprocessing with different final spatial resolution in MNI space
%

clear;
clc;

FWHM = 6;

downloadData = true;

run ../../initCppSpm.m;

%% Set options
opt = FaceRep_getOption();
opt = FaceRep_getOptionResults(opt);

%% Removes previous analysis, gets data and converts it to BIDS
if downloadData

  dowload_convert_face_rep_ds();

end

%% Run batches

reportBIDS(opt);

for iResolution = 1:0.5:3

  opt.funcVoxelDims = repmat(iResolution, 1, 3);

  opt.derivativesDir = spm_file( ...
                                fullfile(opt.dataDir, ...
                                         '..', ...
                                         'derivatives', ...
                                         ['cpp_spm-res' num2str(iResolution)]), 'cpath');

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

function opt =  FaceRep_getOptionResults(opt)

  opt.model.file = fullfile( ...
                            fileparts(mfilename('fullpath')), ...
                            'models', ...
                            'model-faceRepetition_smdl.json');

  opt.glmQA.do = false;

  % Specify the result to compute
  opt.result.Steps(1) = returnDefaultResultsStructure();

  opt.result.Steps(1).Level = 'subject';

  opt.result.Steps(1).Contrasts(1).Name = 'faces_gt_baseline';

  opt.result.Steps(1).Contrasts(1).MC =  'FWE';
  opt.result.Steps(1).Contrasts(1).p = 0.05;
  opt.result.Steps(1).Contrasts(1).k = 5;

  % Specify how you want your output (all the following are on false by default)
  opt.result.Steps(1).Output.png = true();

  opt.result.Steps(1).Output.csv = true();

  opt.result.Steps(1).Output.thresh_spm = true();

  opt.result.Steps(1).Output.binary = true();

  % MONTAGE FIGURE OPTIONS
  opt.result.Steps(1).Output.montage.do = true();
  opt.result.Steps(1).Output.montage.slices = -26:3:6; % in mm
  % axial is default 'sagittal', 'coronal'
  opt.result.Steps(1).Output.montage.orientation = 'axial';

end
