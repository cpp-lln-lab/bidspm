% (C) Copyright 2019 CPP BIDS SPM-pipeline developers

function opt = get_option()
  % opt = getOption()
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX.

  if nargin < 1
    opt = [];
  end

  % task to analyze
  opt.taskName = 'visMotion';

  % The directory where the data are located
  opt.dataDir = '/home/remi/gin/CPP_visMotion/raw';
  opt.derivativesDir = '/home/remi/Documents';

  % specify the model file that contains the contrasts to compute
  opt.model.file = './vismotion/models/model-visMotionLoc_smdl.json';

  % specify the result to compute
  % Contrasts.Name has to match one of the contrast defined in the model json file
  opt.result.Steps(1) = struct( ...
                               'Level',  'dataset', ...
                               'Contrasts', struct( ...
                                                   'Name', 'VisMot_gt_VisStat', ... %
                                                   'Mask', false, ...
                                                   'MC', 'FWE', ... FWE, none, FDR
                                                   'p', 0.05, ...
                                                   'k', 0, ...
                                                   'NIDM', true));

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
