function opt = face_rep_get_option()
  %
  % returns a structure that contains the options chosen by the user to run
  % slice timing correction, pre-processing, FFX, RFX.
  %
  % (C) Copyright 2020 Remi Gau

  opt = [];

  opt.taskName = 'facerepetition';
  opt.pipeline.type = 'preproc';

  opt.dir.raw = fullfile(fileparts(mfilename('fullpath')), 'outputs', 'raw');
  opt.dir.derivatives = fullfile(opt.dir.raw, '..', 'derivatives');

  %% DO NOT TOUCH
  opt = checkOptions(opt);
  saveOptions(opt);

end
