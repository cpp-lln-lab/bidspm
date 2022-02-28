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

  bm = bids.Model('file', modelFile);
  transformers = bm.get_transformations('Level', nodeType);
  if ~isempty(transformers)
    transformers = transformers.Instructions;
  else
    transformers = struct([]);
  end

end
