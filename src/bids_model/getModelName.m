function name = getModelName(modelFile)
  %
  % returns the model names oa BIDS statistical model
  %
  % (C) Copyright 2022 CPP_SPM developers

  model = bids.util.jsondecode(modelFile);

  name = model.Name;

end
