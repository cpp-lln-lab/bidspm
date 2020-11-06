% (C) Copyright 2020 Agah Karakuzu
% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function retval = isOctave()
  %
  % Short description of what the function does goes here.
  %
  % USAGE::
  %
  %   [argout1, argout2] = templateFunction(argin1, [argin2 == default,] [argin3])
  %
  %
  % :returns: - :argout1: (type) (dimension)
  %

  % Return: true if the environment is Octave.
  persistent cacheval   % speeds up repeated calls

  if isempty (cacheval)
    cacheval = (exist ('OCTAVE_VERSION', 'builtin') > 0);
  end

  retval = cacheval;
end
