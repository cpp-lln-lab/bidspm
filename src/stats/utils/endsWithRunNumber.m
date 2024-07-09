function value = endsWithRunNumber(contrastName)
  %
  % USAGE::
  %
  %   endsWithRunNumber(contrastName)
  %
  %
  % Returns true if the contrast name is that for a run.
  %

  % (C) Copyright 2024 bidspm developers
  result = regexp(contrastName, '_run-[0-9]*$', 'match');
  value =  ~isempty(result);
  return
