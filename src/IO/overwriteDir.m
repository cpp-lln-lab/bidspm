function overwriteDir(directory, opt)
  %
  % USAGE::
  %
  %     overwriteDir(directory, opt)
  %

  % (C) Copyright 2021 bidspm developers

  if exist(directory, 'dir') == 7
    msg = sprintf('\noverwriting directory:\n\t%s\n\n', pathToPrint(directory));
    id = 'overWritingDir';
    logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);
    rmdir(directory, 's');
  end
  spm_mkdir(directory);
end
