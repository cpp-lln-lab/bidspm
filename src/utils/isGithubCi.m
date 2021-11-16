function [IS_GITHUB, pth] = isGithubCi()
  % (C) Copyright 2021 Remi Gau
  IS_GITHUB = false;

  GITHUB_WORKSPACE = getenv('HOME');

  if strcmp(GITHUB_WORKSPACE, '/home/runner')

    fprintf(1, '\n WE ARE RUNNING IN GITHUB CI\n');

    IS_GITHUB = true;
    pth = GITHUB_WORKSPACE;

  else

    fprintf(1, '\n WE ARE NOT RUNNING IN GITHUB CI\n');

  end

end
