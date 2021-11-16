function dataDir = getBidsExample(dataset)
  %
  % (C) Copyright 2021 CPP_SPM developers

  thisDir = fileparts(mfilename('fullpath'));

  dataDir = spm_file(fullfile(thisDir, '..', 'bids-examples', dataset), 'cpath');

end
