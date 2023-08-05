function scrubbed = returnNumberScrubbedTimePoints(confounds)
  % Return number of regressors that have one and only 1 in the whole column.

  % (C) Copyright 2023 bidspm developers
  confounds(isnan(confounds)) = 0;
  isScrubbingConfound = sum(confounds == 1, 1) == 1;
  scrubbingConfounds = confounds(:, isScrubbingConfound);
  scrubbed = sum(sum(scrubbingConfounds, 2));

end
