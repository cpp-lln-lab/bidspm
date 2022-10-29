function createDummyData()
  %

  % (C) Copyright 2022 bidspm developers

  startDir = pwd;

  script = fullfile(getTestDir(), 'createDummyDataSet.sh');

  cd(fileparts(script));

  [status, result] = system('rm -fr dummyData/derivatives/bidspm-preproc/sub-*'); %#ok<*ASGLU>
  [status, result] = system('rm -fr dummyData/derivatives/bidspm-stats/sub-*');
  [status, result] = system('rm -fr dummyData/bidspm-raw/sub-*');
  [status, result] = system('rm -fr dummyData/derivatives/bidspm-stats/group');
  [status, result] = system('rm -fr dummyData/derivatives/bidspm-*/jobs');

  system('sh createDummyDataSet.sh');

  cd(startDir);

end
