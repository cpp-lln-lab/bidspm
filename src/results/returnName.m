function name = returnName(contrast)
  %
  % To help naming of files generated when computing results of a given contrast
  %
  % (C) Copyright 2019 bidspm developers

  name = sprintf('%s_p-%s_k-%i_MC-%s', ...
                 contrast.name, ...
                 convertPvalueToString(contrast.p), ...
                 contrast.k, ...
                 contrast.MC);

  name = strrep(name, '0.', '');

end
