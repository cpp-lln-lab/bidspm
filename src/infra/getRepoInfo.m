function [branch, commit] = getRepoInfo(rootDir)
  %
  % Return the branch and commit shasum
  %
  % USAGE::
  %
  %   [branch, commit] = getRepoInfo()
  %
  % (C) Copyright 2022 CPP_SPM developers

  if nargin < 1
    rootDir = returnRootDir;
  end

  WD = pwd;
  cd(rootDir);

  try
    [~, branch] = system('git rev-parse --abbrev-ref HEAD');
    branch = strrep(branch, newline, '');
  catch
    branch = 'unknown';
  end

  try
    [~, commit] = system('git rev-parse --short HEAD');
    commit = strrep(commit, newline, '');
  catch
    commit = 'unknown';
  end

  cd(WD);

end
