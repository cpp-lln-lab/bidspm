function syntheticDataDir = getSyntheticDataDir()
  %
  % (C) Copyright 2021 CPP_SPM developers

  thisDir = fileparts(mfilename('fullpath'));

  syntheticDataDir = spm_file(fullfile(thisDir, '..', 'bids-examples', 'synthetic'), 'cpath');

end
