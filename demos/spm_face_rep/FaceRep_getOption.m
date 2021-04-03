% (C) Copyright 2020 Remi Gau

function opt = FaceRep_getOption()
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX.

  opt = [];

  % task to analyze
  opt.taskName = 'facerepetition';

  % The directory where the data are located
  opt.dataDir = fullfile(fileparts(mfilename('fullpath')), 'outputs', 'raw');

  opt.stats.dir = fullfile(opt.dataDir, '..', 'derivatives', 'cpp_spm-stats');

  opt.model.hrfDerivatives = [1 1];

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
