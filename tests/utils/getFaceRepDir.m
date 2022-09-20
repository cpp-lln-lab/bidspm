function facerepDir = getFaceRepDir()
  %
  % (C) Copyright 2022 bidspm developers

  facerepDir = spm_file(fullfile(getTestDir(), '..', 'demos', 'face_repetition'), 'cpath');

end
