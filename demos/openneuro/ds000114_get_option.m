% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function opt = ds000114_get_option()
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX.

  if nargin < 1
    opt = [];
  end

  % The directory where the data are located
  opt.dataDir = '/home/remi/openneuro/ds000114/raw';

  % suject to run in each group
  opt.subjects = {'01', '02'};

  % task to analyze
  opt.taskName = 'linebisection';

  opt.anatReference.type = 'T1w';
  opt.anatReference.session = 2;

  % Uncomment the lines below to run preprocessing
  % - don't use realign and unwarp
  %   opt.realign.useUnwarp = false;
  % - in "native" space: don't do normalization
  %   opt.space = 'individual';

  opt.model.file = fullfile(fileparts(mfilename('fullpath')), ...
                            'models', ...
                            'model-ds000114-linebisection_smdl.json');

  % specify the result to compute
  opt.result.Steps(1) = struct( ...
                               'Level',  'subject', ...
                               'Contrasts', struct( ...
                                                   'Name', 'Correct_Task', ... % has to match
                                                   'Mask', false, ...
                                                   'MC', 'FWE', ... FWE, none, FDR
                                                   'p', 0.05, ...
                                                   'k', 0));

  opt.parallelize.do = true;
  opt.parallelize.nbWorkers = 2;
  opt.parallelize.killOnExit = false;

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
