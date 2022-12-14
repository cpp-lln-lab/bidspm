function cleanUpWorkflow(opt)
  %
  % USAGE::
  %
  %   cleanUpWorkflow(opt)
  %

  % (C) Copyright 2021 bidspm developers

  if isfield(opt, 'globalStart')
    elapsedTime(opt, 'globalStop');
  end

end
