function name = returnName(result)
  %
  % To help naming of files generated when computing results of a given contrast
  %
  % (C) Copyright 2019 CPP_SPM developers

  name = sprintf('%s_p-%s_k-%i_MC-%s', ...
                 result.Contrasts.Name, ...
                 convertPvalueToString(result.Contrasts.p), ...
                 result.Contrasts.k, ...
                 result.Contrasts.MC);

  name = strrep(name, '0.', '');

end
