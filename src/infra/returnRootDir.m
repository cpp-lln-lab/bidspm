function rootDir = returnRootDir()
  %
  % USAGE::
  %
  %   rootDir = returnRootDir()
  %
  % (C) Copyright 2022 CPP_SPM developers

  Mfile = 'cpp_spm.m';
  rootDir = cellstr(which(Mfile, '-ALL'));

  % convert to absolute paths and keep unique ones
  for i = 1:numel(rootDir)
    rootDir{i} = spm_file(fullfile(fileparts(rootDir{i})), 'cpath');
  end

  rootDir = unique(rootDir);

  if isempty(rootDir)
    err.message = 'CPP_SPM is not in your MATLAB / Octave path.\n';
    err.identifier = 'CPP_SPM:CppSpmNotInPath';
    error(err);

  elseif numel(rootDir) > 1
    fprintf('CPP_SPM seems to appear in several different folders:\n');
    for i = 1:numel(rootDir)
      fprintf('  * %s\n', fullfile(rootDir{i}, '..', '..'));
    end
    err.message = 'Remove all but one with ''pathtool''.\n'; % or ''spm_rmpath
    err.identifier = 'CPP_SPM:SeveralCppSpmInPath';
    error(err);

  end

  rootDir = rootDir{1};

end
