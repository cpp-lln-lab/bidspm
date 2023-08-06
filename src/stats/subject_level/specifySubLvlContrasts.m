function [contrasts, counter] = specifySubLvlContrasts(node, SPM, contrasts, counter)
  %
  %
  %
  % USAGE::
  %
  %   [contrasts, counter] = specifySubLvlContrasts(node, SPM, contrasts, counter)
  %
  % :param contrasts:
  % :type  contrasts: struct
  %
  % :param node:
  % :type  node:
  %
  % :param counter:
  % :type  counter: integer
  %
  % :param SPM:
  % :type  SPM: struct
  %
  %
  % See also: specifyContrasts
  %

  % (C) Copyright 2022 bidspm developers

  if ~isfield(node, 'Contrasts')
    return
  end

  % include contrasts that involve contrasting conditions
  % amongst themselves or inferior to baseline
  for iCon = 1:length(node.Contrasts)

    this_contrast = checkContrast(node, iCon);

    if isempty(this_contrast) || strcmp(this_contrast.Test, 'pass')
      continue
    end

    conditionList = this_contrast.ConditionList;

    C = newContrast(SPM, this_contrast.Name, this_contrast.Test, conditionList);
    this_contrast.Name;

    row = 1;

    for iCdt = 1:length(conditionList)

      cdtName = conditionList{iCdt};
      [~, regIdx, status] = getRegressorIdx(cdtName, SPM);

      if ~status
        break
      end

      regIdx = find(regIdx);

      % give them the value specified in the model
      if strcmp(this_contrast.Test, 't')
        C.C(end, regIdx) = this_contrast.Weights(iCdt);

      elseif strcmp(this_contrast.Test, 'F')
        for i = 1:numel(regIdx)
          C.C(row, regIdx(i)) = this_contrast.Weights(iCdt);
          row = row + 1;
        end

      end

      clear regIdx;

    end

    % do not create this contrast if a condition is missing
    if ~status
      msg = sprintf('Skipping contrast %s: runs are missing condition %s', ...
                    this_contrast.Name, cdtName);
      id = 'runMissingCondition';
      logger('WARNING', msg, 'id', id, 'filename', mfilename());

    else
      [contrasts, counter] = appendContrast(contrasts, C, counter, this_contrast.Test);

    end

  end

end
