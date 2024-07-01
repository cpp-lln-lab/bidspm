function value = endsWithRunNumber(contrastName)
  %
  % USAGE::
  %
  %   endsWithRunNumber(contrastName)
  %

  % (C) Copyright 2024 bidspm developers
  value =  isempty(regexp(contrastName, '_[0-9]+\${0,1}$', 'match'));
  return
