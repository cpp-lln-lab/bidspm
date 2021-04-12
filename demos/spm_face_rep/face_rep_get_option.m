% (C) Copyright 2020 Remi Gau

function opt = face_rep_get_option()
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX.

  opt = [];

  opt.taskName = 'facerepetition';

  opt.dataDir = fullfile(fileparts(mfilename('fullpath')), 'outputs', 'raw');
  opt.dir.roi = fullfile(opt.dataDir, '..', 'derivatives', 'cpp_spm-roi');

  opt.model.hrfDerivatives = [1 1];

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
