function createDummyData()
  %

  % (C) Copyright 2022 bidspm developers

  startDir = pwd;

  script = fullfile(getTestDir(), 'createDummyDataSet.sh');

  cd(fileparts(script));

  [status, result] = system('rm -fr data/derivatives/bidspm-preproc/sub-*'); %#ok<*ASGLU>
  [status, result] = system('rm -fr data/derivatives/bidspm-stats/sub-*');
  [status, result] = system('rm -fr data/bidspm-raw/sub-*');
  [status, result] = system('rm -fr data/derivatives/bidspm-stats/group');
  [status, result] = system('rm -fr data/derivatives/bidspm-*/jobs');

  system('sh createDummyDataSet.sh');

  cd(startDir);

  generateLayoutMat(true);

end
