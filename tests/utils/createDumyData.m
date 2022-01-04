function createDumyData()
  %
  % (C) Copyright 2022 CPP_SPM developers

  thisDir = fileparts(mfilename('fullpath'));
  script = fullfile(thisDir, '..', 'createDummyDataSet.sh');

  cd(fileparts(script));
  system('sh createDummyDataSet.sh');
  cd(thisDir);

end
