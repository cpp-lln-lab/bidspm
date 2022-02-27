function variablesToConvolve = getVariablesToConvolve(modelFile, nodeType)
  %
  % returns the variables to convolve from a BIDS stats model
  %
  % (C) Copyright 2021 CPP_SPM developers

  if isempty(modelFile)
    return
  end
  if nargin < 2 || isempty(nodeType)
    nodeType = 'run';
  end

  bm = bids.Model('file', modelFile);
  node = bm.get_nodes('Level', nodeType);

  variablesToConvolve = [];
  if ~isfield(node.Model, 'HRF') || ...
      ~isfield(node.Model.HRF, 'Variables')

    msg = sprintf('No variables to convolve mentioned for node %s in BIDS model file\n%s', ...
                  nodeType, modelFile);
    errorHandling(mfilename(), 'noVariablesToConvolve', msg, true, true);

  else
    variablesToConvolve = node.Model.HRF.Variables;

  end

end
