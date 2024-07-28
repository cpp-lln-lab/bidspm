function [type, srcDesignMatrix, groupBy] = groupLevelGlmType(opt, nodeName, participants)
  %

  % (C) Copyright 2022 bidspm developers

  if nargin < 3
    participants = struct();
  end

  % TODO refactor
  columns = fieldnames(participants);

  node = opt.model.bm.get_nodes('Name', nodeName);
  groupBy = node.GroupBy;
  srcDesignMatrix = node.Model.X;

  type = 'unknown';
  if isnumeric(srcDesignMatrix) && srcDesignMatrix == 1
    type = 'one_sample_t_test';

  elseif iscell(srcDesignMatrix) && numel(srcDesignMatrix) == 2

    designMatrix = cellfun(@(x) num2str(x), srcDesignMatrix, 'uniformoutput', false);

    for i = 1:numel(columns)
      if all(ismember(designMatrix, {'1', columns{i}}))
        levels = participants.(columns{i});
        switch numel(unique(levels))
          case 1
            type = 'one_sample_t_test';
          case 2
            type = 'two_sample_t_test';
          otherwise
            type = 'one_way_anova';
        end
        break
      end
    end

  end

end
