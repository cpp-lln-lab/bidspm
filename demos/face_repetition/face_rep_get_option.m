function opt = face_rep_get_option()
  %
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX.
  %
  % (C) Copyright 2020 Remi Gau

  opt = [];

  opt.taskName = 'facerepetition';

  opt.dir.raw = fullfile(fileparts(mfilename('fullpath')), 'outputs', 'raw');
  opt.dir.roi = fullfile(opt.dir.raw, '..', 'derivatives', 'cpp_spm-roi');
  opt.dir.derivatives = fullfile(opt.dir.raw, '..', 'derivatives', 'cpp_spm-preprocess');

  opt.model.hrfDerivatives = [1 1];

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
