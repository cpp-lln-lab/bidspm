function overwriteDir(directory, opt)
  %
  % USAGE::
  %
  %     overwriteDir(directory, opt)
  %
  % (C) Copyright 2021 CPP_SPM developers

  if exist(directory, 'dir') == 7
    msg = sprintf('overwriting directory: %s \n', pathToPrint(directory));
    errorHandling(mfilename(), 'overWritingDir', msg, true, opt.verbosity);
    rmdir(directory, 's');
  end
  spm_mkdir(directory);
end
