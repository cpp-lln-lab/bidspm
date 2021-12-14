function HPF = getHighPassFilter(modelFile, nodeType)
  %
  % returns the HPF of a node of a BIDS statistical model
  %
  % (C) Copyright 2021 CPP_SPM developers

  HPF = '';

  if isempty(modelFile)
    return
  end
  if nargin < 2 || isempty(nodeType)
    nodeType = 'run';
  end

  model = bids.util.jsondecode(modelFile);

  node = returnModelNode(model, nodeType);

  if ~isfield(node.Model.Options, 'HighPassFilterCutoffHz') || ...
          isempty(node.Model.Options.HighPassFilterCutoffHz)
    msg = sprintf('No high-pass filter mentioned for node %s in BIDS model file\%s', ...
                  nodeType, modelFile);
    errorHandling(mfilename(), 'noHighPassFilter', msg, false, true);
  else
    HPF = 1 / node.Model.Options.HighPassFilterCutoffHz;
  end

end
