function [IS_GITHUB, pth] = isGithubCi()

    IS_GITHUB = false;   
    
    GITHUB_WORKSPACE = getenv('GITHUB_WORKSPACE');

    if strcmp(GITHUB_WORKSPACE, '/github/workspace')

        IS_GITHUB = true;
        pth = GITHUB_WORKSPACE;

    end

end