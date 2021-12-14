function contrastsList = getContrastsList(modelFile, nodeType)
  %
  % (C) Copyright 2021 Remi Gau

  contrastsList = '';

  if isempty(modelFile)
    return
  end
  if nargin < 2 || isempty(nodeType)
    nodeType = 'run';
  end

  model = bids.util.jsondecode(modelFile);

  node = returnModelNode(model, nodeType);

  contrastsList = node.Contrasts;

end
