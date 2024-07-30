function createDummyData()
  %

  % (C) Copyright 2022 bidspm developers

  startDir = pwd;

  script = fullfile(getTestDir(), 'create_dummy_dataset.py');

  cd(fileparts(script));

  [status, result] = system('rm -fr data/derivatives/bidspm-preproc/sub-*'); %#ok<*ASGLU>
  [status, result] = system('rm -fr data/derivatives/bidspm-stats/sub-*');
  [status, result] = system('rm -fr data/bidspm-raw/sub-*');
  [status, result] = system('rm -fr data/derivatives/bidspm-stats/group');
  [status, result] = system('rm -fr data/derivatives/bidspm-*/jobs');

  system('python create_dummy_dataset.py');
  system('python create_3_groups_dataset.py');

  cd(startDir);

  generateLayoutMat(true);

end
