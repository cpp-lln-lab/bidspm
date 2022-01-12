function rootDir = returnRootDir()
  rootDir = fullfile(fileparts(mfilename('fullfile')), '..', '..');
  rootDir =  spm_file(rootDir, 'cpath');
end