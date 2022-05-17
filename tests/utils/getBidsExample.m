function dataDir = getBidsExample(dataset)
  %
  % (C) Copyright 2021 CPP_SPM developers

  dataDir = spm_file(fullfile(getTestDir(), 'bids-examples', dataset), 'cpath');

end
