function [step, iStep] = returnModelStep(model, nodeType)
  %
  % (C) Copyright 2021 Remi Gau

  iStep = nan;
  step = {};
  
  nbSteps = numel(model.Steps);
  
  if nbSteps == 1
      model.Steps = {model.Steps};
  end

  levels = cellfun(@(x) x.Level, model.Steps, 'UniformOutput', false);
  
  idx = ismember(levels, nodeType);
  if any(idx)
    step = model.Steps{idx};
    iStep = find(idx);
  else
    msg = sprintf('could not find a model step of type %s', nodeType);
    errorHandling(mfilename(), 'missingModelStep', msg, false, true)
  end

end
