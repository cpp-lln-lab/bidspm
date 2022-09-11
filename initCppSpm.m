function initCppSpm(dev)
  % (C) Copyright 2021 bidspm developers

  if nargin < 1
    dev = false;
  end

  warning(['"initCppSpm" will be deprecated in the next major release.\n', ...
           'Please use the "bidspm()" or "bidspm(''action'', ''dev'')" instead.']);

  if dev
    bidspm('action', 'dev');
  else
    bidspm();
  end

end
