% (C) Copyright 2019 CPP BIDS SPM-pipeline developpers

function opt = ds001168_getOption()
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX.

  if nargin < 1
    opt = [];
  end

  % The directory where the data are located
  opt.dataDir = '/home/remi/openneuro/ds001168/raw';

  % suject to run in each group
  opt.subjects = {'01'};

  % task to analyze
  opt.taskName = 'rest';

  opt.anatReference.type = 'T1w';
  opt.anatReference.session = 1;

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  %     saveOptions(opt);

end
