function thisResult = fillInResultStructure(thisResult)
  %
  % Fill a structure use to dsiplay results with defaults
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

  % add missing fields
  thisResult = setFields(thisResult, defaultResults);

  fields = fieldnames(defaultResults);

  % fill in empty fields
  for i = 1:numel(fields)
    if isempty(thisResult.(fields{i}))
      thisResult.(fields{i}) = defaultResults.(fields{i});
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
