function [step, iStep] = returnModelNode(model, nodeType)
  %
  % (C) Copyright 2021 Remi Gau

  iStep = nan;
  step = {};

  nbNodes = numel(model.Nodes);

  if nbNodes == 1
    model.Nodes = {model.Nodes};
  end

  levels = cellfun(@(x) x.Level, model.Nodes, 'UniformOutput', false);

  idx = ismember(levels, nodeType);
  if any(idx)
    step = model.Nodes{idx};
    iStep = find(idx);
  else
    msg = sprintf('could not find a model node of type %s', nodeType);
    errorHandling(mfilename(), 'missingModelNode', msg, false, true);
  end

end
