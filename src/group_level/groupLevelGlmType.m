function [type, designMatrix, groupBy] = groupLevelGlmType(opt, nodeName)
  %
  % (C) Copyright 2022 CPP_SPM developers

  designMatrix = opt.model.bm.getBidsDesignMatrix('Name', nodeName);

  if isnumeric(designMatrix) && designMatrix == 1

    type = 'one_sample_t_test';

    node = opt.model.bm.get_nodes('Name', nodeName);

    groupBy = node.GroupBy;

  elseif iscell(designMatrix) && numel(designMatrix) == 2

    type = 'two_sample_t_test';

  else
    type = 'unknown';

  end

end
