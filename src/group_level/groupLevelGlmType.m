function [type, designMatrix, groupBy] = groupLevelGlmType(opt, nodeName)
  %
  % (C) Copyright 2022 bidspm developers

  designMatrix = opt.model.bm.getBidsDesignMatrix('Name', nodeName);

  node = opt.model.bm.get_nodes('Name', nodeName);

  groupBy = node.GroupBy;

  if isnumeric(designMatrix) && designMatrix == 1

    type = 'one_sample_t_test';

  elseif iscell(designMatrix) && numel(designMatrix) == 2

    type = 'two_sample_t_test';

  else
    type = 'unknown';

  end

end
