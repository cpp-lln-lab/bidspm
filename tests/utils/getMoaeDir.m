function moaeDir = getMoaeDir()
  %
  % (C) Copyright 2021 CPP_SPM developers

  moaeDir = spm_file(fullfile(getTestDir(), '..', 'demos', 'MoAE'), 'cpath');

end
