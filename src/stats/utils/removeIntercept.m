function designMatrix = removeIntercept(designMatrix)
  %
  % remove intercept because SPM includes it anyway
  %

  % (C) Copyright 2021 bidspm developers
  isIntercept = cellfun(@(x) (numel(x) == 1) && (x == 1), designMatrix, 'UniformOutput', true);
  designMatrix(isIntercept) = [];
end
