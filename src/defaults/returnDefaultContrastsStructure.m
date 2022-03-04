function contrasts  = returnDefaultContrastsStructure()
  %
  % (C) Copyright 2022 CPP_SPM developers

  contrasts =  struct('Name', '', ...
                      'useMask', false(), ...
                      'MC', 'FWE', ... % FWE, none, FDR
                      'p', 0.05, ...
                      'k', 0);

end
