function addReadme(fullpath)
  %
  % Adds a basic README
  %
  % USAGE::
  %
  %   addReadme(fullpath)
  %
  % :type  fullpath:
  % :param fullpath: char
  %

  % (C) Copyright 2022 bidspm developers

  spm_mkdir(fullpath);

  outputFile = fullfile(fullpath, 'README.md');

  if exist(outputFile, 'file') == 2

  else
    fid = fopen(outputFile, 'w');
    fprintf(fid, '# README\n');
    fclose(fid);
  end
