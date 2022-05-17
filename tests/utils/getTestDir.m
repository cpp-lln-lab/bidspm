function testDir = getTestDir()
  %
  % (C) Copyright 2022 CPP_SPM developers

  thisDir = fileparts(mfilename('fullpath'));

  testDir = spm_file(fullfile(thisDir, '..'), 'cpath');

end
