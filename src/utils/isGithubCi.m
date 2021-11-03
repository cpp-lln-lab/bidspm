function [IS_GITHUB, pth] = isGithubCi()
  % (C) Copyright 2021 Remi Gau
  IS_GITHUB = false;

  GITHUB_WORKSPACE = getenv('HOME');

  if strcmp(GITHUB_WORKSPACE, '/home/runner')

    IS_GITHUB = true;
    pth = GITHUB_WORKSPACE;

  end

end
