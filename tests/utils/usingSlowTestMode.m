function value = usingSlowTestMode()
  % (C) Copyright 2023 bidspm developers
  global SLOW
  ENV_SLOW = getenv('SLOW');
  value = false;
  if ~isempty(ENV_SLOW) || (~isempty(SLOW) && SLOW)
    value = true;
  end
end
