% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function opt = ds001168_get_option()
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

  % Uncomment the lines below to run preprocessing
  % - don't use realign and unwarp
  %   opt.realign.useUnwarp = false;
  % - in "native" space: don't do normalization
  %   opt.space = 'individual';

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
