function HPF = getHighPassFilter(modelFile, nodeType)
  %
  % returns the design matrix of a node of a BIDS statistical model
  %
  % (C) Copyright 2021 CPP_SPM developers
  
  HPF = '';
  
  if isempty(modelFile)
      return
  end
  if nargin<2 || isempty(nodeType)
      nodeType = 'run';
  end

  model = bids.util.jsondecode(modelFile);

  step = returnModelStep(model, nodeType);

  HPF = step.Model.Options.high_pass_filter_cutoff_secs;

end