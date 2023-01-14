function addGitIgnore(fullpath)
  %
  % Adds a basic gitignore
  %
  % USAGE::
  %
  %   addGitIgnore(fullpath)
  %
  % :type  fullpath:
  % :param fullpath: char
  %

  % (C) Copyright 2022 bidspm developers

  spm_mkdir(fullpath);

  outputFile = fullfile(fullpath, '.gitignore');

  if exist(outputFile, 'file') == 2

    fid = fopen(outputFile, 'a+');

    c = fread(fid, Inf, 'uint8=>char')';
    if ~numel(strfind(c, '.DS_store')) > 0
      fprintf(fid, '.DS_store\n');
    end

    fclose(fid);

  else
    fid = fopen(outputFile, 'w');
    fprintf(fid, '.DS_store\n');
    fclose(fid);
  end

end
