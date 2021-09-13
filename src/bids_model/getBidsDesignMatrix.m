function X = getBidsDesignMatrix(modelFile, nodeType)
  %
  % returns the design matrix of a node of a BIDS statistical model
  %
  % (C) Copyright 2021 CPP_SPM developers

  model = bids.util.jsondecode(modelFile);

  for i = 1:numel(model.Steps)
    step = model.Steps(i);
    if iscell(step)
      step = step{1};
    end
    if strcmp(step.Level, nodeType)
      break
    end
  end

  if ~isfield(step, 'Model')
    msg = sprintf('Missing model specification from the model file:\n %s', modelFile);
    errorHandling(mfilename(), 'missingModel', msg, false);
  end

  X = step.Model.X;

end
