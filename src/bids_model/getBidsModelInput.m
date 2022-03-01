function inputs = getBidsModelInput(modelFile)
  %
  % (C) Copyright 2022 Remi Gau

  if isempty(modelFile)
    return
  end

  bm = bids.Model('file', modelFile);

  inputs = bm.Input;

end
