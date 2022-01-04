function createDummyData()
  %
  % (C) Copyright 2022 CPP_SPM developers

  startDir = pwd;

  thisDir = fileparts(mfilename('fullpath'));
  script = fullfile(thisDir, '..', 'createDummyDataSet.sh');

  cd(fileparts(script));
  system('sh createDummyDataSet.sh');
  cd(startDir);

end
