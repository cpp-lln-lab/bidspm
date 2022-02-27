function contrastsList = getDummyContrastsList(modelFile, nodeType)
  %
  % (C) Copyright 2021 Remi Gau

  contrastsList = '';

  if isempty(modelFile)
    return
  end
  if nargin < 2 || isempty(nodeType)
    nodeType = 'run';
  end

  bm = bids.Model('file', modelFile);
  contrastsList = bm.get_dummy_contrasts('Level', nodeType)

end
