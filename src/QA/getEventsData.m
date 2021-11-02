function data = getEventsData(tsvFile, modelFile, nodeType)
  % (C) Copyright 2020 Remi Gau
  
  % TODO: refactor with convertOnsetTsvToMat
  
  if nargin < 2
      modelFile = '';
  end
  
  if nargin < 3
      nodeType = 'run';
  end
  
    designMatrix = getBidsDesignMatrix(modelFile, nodeType);
  
    content = bids.util.tsvread(tsvFile);

    conditions = unique(content.trial_type);

    data.conditions = conditions;

    for iCdt = 1:numel(conditions)

      idx = strcmp(content.trial_type, conditions{iCdt});
      data.onsets{iCdt} = content.onset(idx); %#ok<*AGROW>
      data.duration{iCdt} = content.duration(idx);

    end

end
