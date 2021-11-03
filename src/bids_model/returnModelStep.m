function [step, iStep] = returnModelStep(model, nodeType)
  %
  % (C) Copyright 2021 Remi Gau

  iStep = nan;
  step = {};

  levels = cellfun(@(x) x.Level, model.Steps, 'UniformOutput', false);
  idx = ismember(levels, nodeType);
  if any(idx)
    step = model.Steps{idx};
    iStep = find(idx);
  end

end
