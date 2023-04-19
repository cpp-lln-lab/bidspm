function thisResult = fillInResultStructure(thisResult)
  %
  % Fill a structure use to display results with defaults
  %
  % USAGE::
  %
  %   thisResult = fillInResultStructure(thisResult)
  %
  % :param thisResult:
  % :type  thisResult: struct
  %

  % (C) Copyright 2022 Remi Gau

  if iscell(thisResult)
    thisResult = thisResult{1};
  end

  defaultResults = defaultResultsStructure();

  % add missing defaultFields
  thisResult = setFields(thisResult, defaultResults);

  defaultFields = fieldnames(defaultResults);

  % fill in empty defaultFields
  for i = 1:numel(defaultFields)
    if isempty(thisResult.(defaultFields{i}))
      thisResult.(defaultFields{i}) = defaultResults.(defaultFields{i});
    end
  end

  % make sure there is no extra field
  currentFields = fieldnames(thisResult);
  for i = 1:numel(currentFields)
    if ~ismember(currentFields{i}, defaultFields)
      unfold(thisResult);
      id = 'unknownResultsField';
      msg = sprintf( ...
                    ['Unknown field ''%s'' in result structure above.\n', ...
                     'Allowed fields include:%s'], ...
                    currentFields{i}, ...
                    bids.internal.create_unordered_list(defaultFields));
      errorHandling(mfilename(), id, msg, false);

    end
  end

  if ischar(thisResult.name)
    thisResult.name = {thisResult.name};
  end
  assert(iscell(thisResult.name));

  assert(all([thisResult.p >= 0 thisResult.p <= 1]));

  assert(thisResult.k >= 0);

  assert(islogical(thisResult.useMask));

  assert(ismember(thisResult.MC, {'FWE', 'FDR', 'none'}));

end
