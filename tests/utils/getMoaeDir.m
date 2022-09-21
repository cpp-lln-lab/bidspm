function moaeDir = getMoaeDir()
  %

  % (C) Copyright 2021 bidspm developers

  moaeDir = spm_file(fullfile(getTestDir(), '..', 'demos', 'MoAE'), 'cpath');

end
