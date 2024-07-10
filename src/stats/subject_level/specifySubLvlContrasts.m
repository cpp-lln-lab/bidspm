function [contrasts, count] = specifySubLvlContrasts(model, node, contrasts, count)
  %
  %
  %
  % USAGE::
  %
  %   [contrasts, counter] = specifySubLvlContrasts(model, node, contrasts, counter)
  %
  % :param model:
  % :type  model: BidsModel instance
  %
  % :param contrasts:
  % :type  contrasts: struct
  %
  % :param node:
  % :type  node: struct
  %
  % :param counter:
  % :type  counter: integer
  %
  %
  % See also: specifyContrasts
  %

  % (C) Copyright 2022 bidspm developers

  if ~isfield(node, 'Contrasts')
    return
  end

  if ~strcmpi(node.Level, 'subject')
    return
  end

  % include contrasts that involve contrasting conditions
  % amongst themselves or inferior to baseline
  for iCon = 1:length(node.Contrasts)

    thisContrast = checkContrast(model, node, iCon);

    if isempty(thisContrast) || strcmp(thisContrast.Test, 'pass')
      continue
    end

    if isnumeric(node.Model.X) && node.Model.X == 1
      [contrasts, count] = averageAtSubjectLevel(model, ...
                                                 contrasts, ...
                                                 count, ...
                                                 thisContrast);

    elseif iscell(node.Model.X) && ...
            all(cellfun(@(x) strcmp(x, 'session') || x == 1, node.Model.X))
      [contrasts, count] = crossSesContrast(model, ...
                                            node, ...
                                            thisContrast, ...
                                            contrasts, ...
                                            count);
    end

  end

end

function  [contrasts, count] = crossSesContrast(model, node, thisContrast, contrasts, count)
  % loop over contrasts from previous levels to do a cross session comparison
  sessionList = thisContrast.ConditionList;

  if ~strcmp(thisContrast.Test, 't')
    return
  end

  % collect contrasts from previous runs
  % TODO
  % dummyContrastsList = getDummyContrastFromParentNode(model, node);
  contrastsList = getContrastsFromParentNode(model, node);

  for iCon = 1:numel(contrastsList)

    contrastName = [thisContrast.Name '-' contrastsList{iCon}.Name];
    C = newContrast(model.SPM, contrastName, thisContrast.Test, sessionList);

    for iSes = 1:length(sessionList)
      % apply weight specified in previous level
      % multiplied by weight for each sessions
      for iCdt = 1:numel(contrastsList{iCon}.ConditionList)
        cdtName = contrastsList{iCon}.ConditionList{iCdt};
        [~, regIdx] = getRegressorIdx(cdtName, model.SPM, sessionList{iSes});
        C.C(end, regIdx) = contrastsList{iCon}.Weights(iCdt) * ...
            thisContrast.Weights(iSes);
      end
    end

    [contrasts, count] = appendContrast(contrasts, C, count, thisContrast.Test);

  end

end

function [contrasts, count] = averageAtSubjectLevel(model, contrasts, count, thisContrast)

  conditionList = thisContrast.ConditionList;

  C = newContrast(model.SPM, thisContrast.Name, thisContrast.Test, conditionList);

  row = 1;

  for iCdt = 1:length(conditionList)

    cdtName = conditionList{iCdt};
    if isempty(cdtName)
      continue
    end

    [~, regIdx, status] = getRegressorIdx(cdtName, model.SPM);
    if ~status
      break
    end

    regIdx = find(regIdx);

    % give them the value specified in the model
    if strcmp(thisContrast.Test, 't')
      C.C(end, regIdx) = thisContrast.Weights(iCdt);

    elseif strcmp(thisContrast.Test, 'F')

      for i = 1:numel(regIdx)
        for i_w = 1:size(thisContrast.Weights, 1)
          C.C(row, regIdx(i)) = thisContrast.Weights(i_w, iCdt);
          row = row + 1;
        end
      end

    end

    clear regIdx;

  end

  rows_to_rm = all(C.C == 0, 2);
  C.C(rows_to_rm, :) = [];

  % do not create this contrast if a condition is missing
  if exist('status', 'var')
    if ~status
      msg = sprintf('Skipping contrast %s: runs are missing condition %s', ...
                    thisContrast.Name, cdtName);
      id = 'runMissingCondition';
      logger('WARNING', msg, 'id', id, 'filename', mfilename());

    else
      [contrasts, count] = appendContrast(contrasts, C, count, thisContrast.Test);

    end
  end

end
