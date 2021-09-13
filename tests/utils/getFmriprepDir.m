function fmriprepDir = getFmriprepDir()
  %
  % (C) Copyright 2021 CPP_SPM developers

  thisDir = fileparts(mfilename('fullpath'));

  fmriprepDir = spm_file(fullfile(thisDir, '..', 'bids-examples', 'ds000001-fmriprep'), 'cpath');

end
