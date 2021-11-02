function contrastsList = getAutoContrastsList(modelFile, nodeType)
    
  contrastsList = '';
  
  if isempty(modelFile)
      return
  end
  if nargin<2 || isempty(nodeType)
      nodeType = 'run';
  end

  model = bids.util.jsondecode(modelFile);

  step = returnModelStep(model, nodeType);

  contrastsList = step.AutoContrasts;
    
end