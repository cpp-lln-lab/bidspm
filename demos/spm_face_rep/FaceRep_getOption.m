% (C) Copyright 2019 Remi Gau

function opt = FaceRep_getOption()
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX.

  opt = [];

  % task to analyze
  opt.taskName = 'facerepetition';

  % The directory where the data are located
  opt.dataDir = fullfile(fileparts(mfilename('fullpath')), 'raw');
  
  opt.model.hrfDerivatives = [1 1];

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
