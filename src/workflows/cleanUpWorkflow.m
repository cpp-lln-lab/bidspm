function cleanUpWorkflow(opt)
  %
  % USAGE::
  %
  %   cleanUpWorkflow(opt)
  %
  % (C) Copyright 2021 CPP_SPM developers

  if isfield(opt, 'globalStart')
    elapsedTime(opt, 'globalStop');
  end

end
