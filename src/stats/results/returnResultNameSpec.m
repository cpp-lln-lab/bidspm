function nameSpec = returnResultNameSpec(opt, result)
  %
  % Return a bids.File name specification for a result file
  %

  % (C) Copyright 2023 bidspm developers
  nameSpec.entities.sub = result.label;
  nameSpec.entities.task = strjoin(opt.taskName, '');
  nameSpec.entities.space = result.space{1};
  if isfield(result, 'contrastNb')
    nameSpec.entities.label = sprintf('%04.0f', result.contrastNb);
  end
  nameSpec.entities.desc = result.name;
  nameSpec.entities.p = convertPvalueToString(result.p);
  nameSpec.entities.k = num2str(result.k);
  nameSpec.entities.MC = result.MC;

  fields = fieldnames(nameSpec.entities);
  for i = 1:numel(fields)
    value = nameSpec.entities.(fields{i});
    nameSpec.entities.(fields{i}) = bids.internal.camel_case(value);
  end
end
