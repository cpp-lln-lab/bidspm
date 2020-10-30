% (C) Copyright 2020 CPP BIDS SPM-pipeline developpers

function opt = ds000114_getOption()
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
                                                   'k', 0, ...
                                                   'NIDM', true));

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
