function rootDir = returnRootDir()
  %
  % USAGE::
  %
  %   rootDir = returnRootDir()
  %

  % (C) Copyright 2022 bidspm developers

  Mfile = 'bidspm.m';
  rootDir = cellstr(which(Mfile, '-ALL'));

  % convert to absolute paths and keep unique ones
  for i = 1:numel(rootDir)
    rootDir{i} = spm_file(fullfile(fileparts(rootDir{i})), 'cpath');
  end

  rootDir = unique(rootDir);

  if isempty(rootDir)
    msg = 'bidspm is not in your MATLAB / Octave path.\n';
    id = 'bidspm:bidspmNotInPath';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());

  elseif numel(rootDir) > 1
    fprintf('bidspm seems to appear in several different folders:\n');
    for i = 1:numel(rootDir)
      fprintf('  * %s\n', fullfile(rootDir{i}, '..', '..'));
    end
    msg = 'Remove all but one with ''pathtool''.\n'; % or ''spm_rmpath
    id = 'bidspm:SeveralBidspmInPath';
    logger('ERROR', msg, 'id', id, 'filename', mfilename());

  end

  rootDir = rootDir{1};

end
