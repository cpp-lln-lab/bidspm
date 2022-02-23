function status = isZipped(file)
  %
  % USAGE::
  %
  %    status = isZipped(file)
  %
  % (C) Copyright 2022 CPP_SPM developers

  status = strcmp(spm_file(file, 'ext'), 'gz');
end
