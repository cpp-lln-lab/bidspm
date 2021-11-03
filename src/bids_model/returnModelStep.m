function step = returnModelStep(model, nodeType)

  for i = 1:numel(model.Steps)
    step = model.Steps(i);
    if iscell(step)
      step = step{1};
    end
    if strcmp(step.Level, nodeType)
      break
    end
  end

  if ~isfield(step, 'Model')
    msg = sprintf('Missing model specification from the model file:\n %s', modelFile);
    errorHandling(mfilename(), 'missingModel', msg, false);
  end

end
