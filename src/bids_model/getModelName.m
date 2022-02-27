function name = getModelName(modelFile)
  %
  % returns the model names oa BIDS statistical model
  %
  % (C) Copyright 2022 CPP_SPM developers

  bm = bids.Model('file', modelFile);
  name = bm.Name;

end
