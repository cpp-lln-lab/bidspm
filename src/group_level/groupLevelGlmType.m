function [type, designMatrix] = groupLevelGlmType(opt, nodeName)
  %
  % (C) Copyright 2022 CPP_SPM developers

  designMatrix = opt.model.bm.get_design_matrix('Name', nodeName);

  if isnumeric(designMatrix) && designMatrix == 1

    type = 'one_sample_t_test';

  elseif iscell(designMatrix) && numel(designMatrix) == 2

    type = 'two_sample_t_test';

  else
    type = 'unknown';

  end

end
