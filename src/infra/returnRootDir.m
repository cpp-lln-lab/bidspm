function rootDir = returnRootDir()
  %
  % USAGE::
  %
  %   rootDir = returnRootDir()
  %
  % (C) Copyright 2022 CPP_SPM developers

  rootDir = fullfile(fileparts(mfilename('fullfile')), '..', '..');
  rootDir =  spm_file(rootDir, 'cpath');
end
