function transformers = getBidsTransformers(modelFile, nodeType)
  %
  % (C) Copyright 2022 Remi Gau

  transformers = struct([]);

  if isempty(modelFile)
    return
  end
  if nargin < 2 || isempty(nodeType)
    nodeType = 'run';
  end

  model = bids.util.jsondecode(modelFile);

  node = returnModelNode(model, nodeType);

  if isfield(node, 'Transformations') &&  isfield(node.Transformations, 'Instructions')
    transformers = node.Transformations.Instructions;
  end

end
