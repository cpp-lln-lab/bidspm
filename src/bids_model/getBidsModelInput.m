function inputs = getBidsModelInput(modelFile)
  %
  % (C) Copyright 2022 Remi Gau

  if isempty(modelFile)
    return
  end

  model = bids.util.jsondecode(modelFile);

  inputs = model.Input;

end
