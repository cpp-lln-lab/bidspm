% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function opt = ds000001_getOption()
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX.

  if nargin < 1
    opt = [];
  end

  % suject to run in each group
  opt.subjects = {'01', '02'};

  % task to analyze
  opt.taskName = 'balloonanalogrisktask';

  % The directory where the data are located
  opt.dataDir = '/home/remi/openneuro/ds000001/raw';

  % Uncomment the lines below to run preprocessing
  % - don't use realign and unwarp
  %   opt.realign.useUnwarp = false;
  % - in "native" space: don't do normalization
  %   opt.space = 'individual';

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
