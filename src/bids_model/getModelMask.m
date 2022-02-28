function mask = getModelMask(modelFile, nodeType)
  %
  % returns the mask of a node of a BIDS statistical model
  %
  % (C) Copyright 2021 CPP_SPM developers

  mask =  '';

  if isempty(modelFile)
    return
  end
  if nargin < 2 || isempty(nodeType)
    nodeType = 'run';
  end

  bm = bids.Model('file', modelFile);
  node = bm.get_nodes('Level', nodeType);

  try
    mask = node.Model.Options.Mask;
  catch
    msg = sprintf('No mask for node %s in BIDS model file\n%s', ...
                  nodeType, modelFile);
    errorHandling(mfilename(), 'noHRFderivatives', msg, true, true);
  end

end
