function data = getEventsData(tsvFile, modelFile, nodeType)
  %
  % (C) Copyright 2020 Remi Gau

  % TODO refactor with convertOnsetTsvToMat

  if nargin < 2
    modelFile = '';
  end

  if nargin < 3
    nodeType = 'run';
  end

  content = bids.util.tsvread(tsvFile);

  conditions = unique(content.trial_type);

  designMatrix = getBidsDesignMatrix(modelFile, nodeType);

  if ~isempty(designMatrix)
    tmp = conditions;
    tmp = cellfun(@(x) ['trial_type.' x], tmp, 'UniformOutput', false);
    tmp = intersect(tmp, designMatrix);
    conditions = cellfun(@(x) strrep(x, 'trial_type.', ''), tmp, 'UniformOutput', false);
  end

  if numel(conditions) == 0
    data = [];
  else
    data.conditions = conditions;
  end

  for iCdt = 1:numel(conditions)

    idx = strcmp(content.trial_type, conditions{iCdt});
    data.onset{iCdt} = content.onset(idx); %#ok<*AGROW>
    data.duration{iCdt} = content.duration(idx);

  end

end
