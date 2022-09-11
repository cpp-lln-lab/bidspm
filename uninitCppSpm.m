function uninitCppSpm()
  %
  % (C) Copyright 2021 bidspm developers

  warning(['"uninitCppSpm" will be deprecated in the next major release.\n', ...
           'Please use "bidspm(''action'', ''uninit'')" instead.']);

  bidspm('action', 'uninit');

end
