% (C) Copyright 2020 Agah Karakuzu
% (C) Copyright 2020 CPP BIDS SPM-pipeline developers

function retval = isOctave()
  %
  % Returns true if the environment is Octave.
  %
  % USAGE::
  %
  %   retval = isOctave()
  %
  % :returns: :retval: (boolean)
  %

  persistent cacheval   % speeds up repeated calls

  if isempty (cacheval)
    cacheval = (exist ('OCTAVE_VERSION', 'builtin') > 0);
  end

  retval = cacheval;
end
