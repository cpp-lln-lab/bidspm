function touch(filename)
  % (C) Copyright 2023 bidspm developers
  [pth, file, ext] = fileparts(filename);
  if isempty(pth)
    pth = pwd;
  end
  spm_mkdir(pth);

  filename = fullfile(pth, [file, ext]);

  fid = fopen(filename, 'w');
  fprintf(fid, 'this is a dummy file');
  fclose(fid);

end
