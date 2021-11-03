function designMatrix = getBidsDesignMatrix(modelFile, nodeType)
  %
  % returns the design matrix of a node of a BIDS statistical model
  %
  % (C) Copyright 2021 CPP_SPM developers

  designMatrix = '';

  if isempty(modelFile)
    return
  end
  if nargin < 2 || isempty(nodeType)
    nodeType = 'run';
  end

  model = bids.util.jsondecode(modelFile);

  step = returnModelStep(model, nodeType);

  designMatrix = step.Model.X;

end
