function threshold = getInclusiveMaskThreshold(modelFile, nodeType)
  %
  % returns the HRF derivatives of a node of a BIDS statistical model
  %
  % (C) Copyright 2021 CPP_SPM developers

  spm_defaults = spm_get_defaults();

  if isempty(modelFile)
    return
  end
  if nargin < 2 || isempty(nodeType)
    nodeType = 'run';
  end

  model = bids.util.jsondecode(modelFile);

  node = returnModelNode(model, nodeType);

  try
    threshold = node.Model.Software.SPM.InclusiveMaskingThreshold;
  catch
    msg = sprintf('No GLM inclusive masking threshold for node %s in BIDS model file\%s', ...
                  nodeType, modelFile);
    errorHandling(mfilename(), 'noMaskingThreshold', msg, true, true);
  end

  if isempty(threshold)
    threshold =  spm_defaults.mask;
    return
  elseif strcmpi(threshold, '-Inf')
    threshold =  -Inf;
  end

end
