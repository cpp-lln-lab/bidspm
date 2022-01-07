function moaeDir = getFaceRepDir()
  %
  % (C) Copyright 2022 CPP_SPM developers

  thisDir = fileparts(mfilename('fullpath'));

  moaeDir = spm_file(fullfile(thisDir, '..', '..', 'demos', 'face_repetition'), 'cpath');

end
