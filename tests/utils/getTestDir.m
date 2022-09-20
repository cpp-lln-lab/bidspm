function testDir = getTestDir()
  %
  % (C) Copyright 2022 bidspm developers

  thisDir = fileparts(mfilename('fullpath'));

  testDir = spm_file(fullfile(thisDir, '..'), 'cpath');

end
