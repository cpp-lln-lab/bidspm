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

  if ischar(thisResult.name)
    thisResult.name = {thisResult.name};
  end

  validateResultsStructure(thisResult);

  assert(iscell(thisResult.name));

end
