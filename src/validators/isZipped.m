function status = isZipped(file)
  %
  % USAGE::
  %
  %    status = isZipped(file)
  %

  % (C) Copyright 2022 bidspm developers

  status = strcmp(spm_file(file, 'ext'), 'gz');
end
