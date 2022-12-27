function addLicense(fullpath)
  %
  % Copy CCO license in directory
  %
  % USAGE::
  %
  %   addLicense(fullpath)
  %
  % :type  fullpath:
  % :param fullpath: char
  %

  % (C) Copyright 2022 bidspm developers

  spm_mkdir(fullpath);

  outputFile = fullfile(fullpath, 'LICENSE');

  inputFile = fullfile(returnRootDir(), 'src', 'reports', 'LICENSE');

  copyfile(inputFile, outputFile);

end
