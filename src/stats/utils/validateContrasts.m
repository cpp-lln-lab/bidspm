function validateContrasts(contrasts)
  %
  % USAGE::
  %
  %   validateContrasts(contrasts)
  %
  % :param contrasts: structure with at least fields "name", "C"
  % :type  contrasts: struct
  %

  % (C) Copyright 2022 bidspm developers

  % all vectors must have same length
  % take first contrast as reference
  vectorsLength = cellfun(@(x) size(x, 2), {contrasts.C});
  vectorWithDifferentLength = vectorsLength ~= length(contrasts(1).C);
  if any(vectorWithDifferentLength)
    names = contrasts(vectorWithDifferentLength).name;
    logger('ERROR', ....
           sprintf('Vector(s) have abnormal for:%s', ...
                   bids.internal.create_unordered_list(names)), ...
           'filename', mfilename, ...
           'id', 'longerContrast');
  end

  weightVectorIsAllZero = cellfun(@(x) all(x(:) == 0), ...
                                  {contrasts.C}, ...
                                  'UniformOutput', false);
  if any(cellfun(@(x) x == 1, weightVectorIsAllZero))
    names = contrasts(weightVectorIsAllZero).name;
    logger('ERROR', ....
           sprintf('Empty contrast vector(s) for:%s', ...
                   bids.internal.create_unordered_list(names)), ...
           'filename', mfilename, ...
           'id', 'emptyContrast');
  end
end
