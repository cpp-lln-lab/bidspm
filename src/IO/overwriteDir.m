function overwriteDir(directory, opt)
  %
  % USAGE::
  %
  %     overwriteDir(directory, opt)
  %

  % (C) Copyright 2021 bidspm developers

  if exist(directory, 'dir') == 7
    formatted_directory = bids.internal.format_path(directory);
    msg = sprintf('\noverwriting directory:\n\t%s\n\n', formatted_directory);
    id = 'overWritingDir';
    logger('WARNING', msg, 'id', id, 'filename', mfilename(), 'options', opt);
    rmdir(directory, 's');
  end
  spm_mkdir(directory);
end
