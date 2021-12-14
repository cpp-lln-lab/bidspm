function modelType = getModelType(modelFile, nodeType)
  %
  % returns the model type of node of a BIDS statistical model
  %
  % (C) Copyright 2021 CPP_SPM developers

  modelType = '';

  if isempty(modelFile)
    return
  end
  if nargin < 2 || isempty(nodeType)
    nodeType = 'run';
  end

  model = bids.util.jsondecode(modelFile);

  node = returnModelNode(model, nodeType);

  try
    modelType = node.Model.Model.type;
  catch
  end

  if strcmpi(modelType, 'glm')
    msg = sprintf('The model type is not GLM for node %s in BIDS model file\%s', ...
                  nodeType, modelFile);
    errorHandling(mfilename(), 'notGLM', msg, false, true);
  end

end
