function status = checkSpmMat(dir, opt, strict)
  % (C) Copyright 2019 bidspm developers
  status = exist(fullfile(dir, 'SPM.mat'), 'file');
  if nargin < 2
    opt = struct('verbosity', 2);
  end
  if nargin < 3
    strict = false;
  end
  if ~status
    msg = sprintf('\nCould not find a SPM.mat file in directory:\n%s\n', dir);
    id = 'noSpmMatFile';
    if strict
      logger('ERROR', msg, 'id', id, 'options', opt, 'filename', mfilename);
    else
      logger('WARNING', msg, 'id', id, 'options', opt, 'filename', mfilename);
    end
  end
end
