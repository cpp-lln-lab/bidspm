function validateResultsStructure(result)
  % make sure there is no extra field in the result structure
  % of a bids stats model or in the
  %
  %
  % USAGE::
  %
  %   validateResultsStructure(result)
  %

  % (C) Copyright 2022 Remi Gau
  defaultResults = defaultResultsStructure();
  defaultFields = fieldnames(defaultResults);

  currentFields = fieldnames(result);
  for i = 1:numel(currentFields)
    if ~ismember(currentFields{i}, defaultFields)
      unfold(result);
      id = 'unknownResultsField';
      msg = sprintf( ...
                    ['Unknown field ''%s'' in result structure above.\n', ...
                     'Allowed fields include:%s'], ...
                    currentFields{i}, ...
                    bids.internal.create_unordered_list(defaultFields));
      errorHandling(mfilename(), id, msg, false);

    end
  end

  assert(all([result.p >= 0 result.p <= 1]));

  assert(result.k >= 0);

  assert(islogical(result.useMask));

  assert(ismember(result.MC, {'FWE', 'FDR', 'none'}));

end
