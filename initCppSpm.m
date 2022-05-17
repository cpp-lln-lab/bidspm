function initCppSpm(dev)
  %
  % Adds the relevant folders to the path for a given session.
  % Has to be run to be able to use CPP_SPM.
  %
  % USAGE::
  %
  %   initCppSpm()
  %
  % (C) Copyright 2021 CPP_SPM developers

  if nargin < 1
    dev = false;
  end

  if dev
    cpp_spm('action', 'dev');
  else
    cpp_spm();
  end

end
