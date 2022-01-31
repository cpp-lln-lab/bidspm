function rootDir = returnRootDir()
  %
  % USAGE::
  %
  %   rootDir = returnRootDir()
  %
  % (C) Copyright 2022 CPP_SPM developers

  Mfile = 'bidsSpatialPrepro.m';
  rootDir = cellstr(which(Mfile, '-ALL'));

  if isempty(rootDir)
    error('CPP_SPM is not in your MATLAB / Octave path.\n');

  elseif numel(rootDir) > 1
    fprintf('CPP_SPM seems to appear in several different folders:\n');
    for i = 1:numel(rootDir)
      fprintf('  * %s\n', fullfile(rootDir{i}, '..', '..'));
    end
    error('Remove all but one with ''pathtool''' .\ n'); % or ''spm_rmpath

  end

  rootDir = spm_file(fullfile(fileparts(rootDir{1}), '..', '..', '..'), 'cpath');

end
