function contrasts = specifyContrasts(SPM, model)
  %
  % Specifies the first level contrasts
  %
  % USAGE::
  %
  %   contrasts = specifyContrasts(SPM, taskName, model)
  %
  % :param SPM: content of SPM.mat
  % :type SPM: structure
  % :param opt:
  % :type opt: structure
  %
  % :returns: - :contrasts: (type) (dimension)
  %
  % To know the names of the columns of the design matrix, type :
  % ``strvcat(SPM.xX.name)``
  %
  %
  % (C) Copyright 2019 CPP_SPM developers

  % TODO refactor code duplication between run level and subject level

  % TODO refactor with some of the functions from the bids-model folder ?

  % TODO what is the expected behavior if a condition is not present ?
  % - create a contrast with the name dummy ?
  % - do not create the contrast ?

  contrasts = struct('C', [], 'name', []);
  counter = 0;

  if numel(model.Nodes) < 1
    errorHandling(mfilename(), 'wrongStatsModel', 'No node in the model', true, true);
  end

  % check all the nodes specified in the model
  for iNode = 1:length(model.Nodes)

    node = model.Nodes(iNode);

    if iscell(node)
      node = node{1};
    end

    [contrasts, counter] = specifylDummyContrasts(contrasts, node, counter, SPM, node.Level);

    switch lower(node.Level)

      case 'run'

        [contrasts, counter] = specifyRunLvlContrasts(contrasts, node, counter, SPM);

      case 'subject'

        [contrasts, counter] = specifySubLvlContrasts(contrasts, node, counter, SPM);

    end

  end

  if numel(contrasts) == 1 && isempty(contrasts.C)
    msg = 'No contrast to build';
    errorHandling(mfilename(), 'noContrast', msg, false, true);
  end

end

function [contrasts, counter] = specifylDummyContrasts(contrasts, node, counter, SPM, level)

  if strcmpi(level, 'dataset')
    return
  end

  if ~isfield(node, 'DummyContrasts')
    return
  end

  if isfield(node.DummyContrasts, 'Contrasts') && ...
          isTtest(node.DummyContrasts)

    % first the contrasts to compute automatically against baseline
    for iCon = 1:length(node.DummyContrasts.Contrasts)

      cdtName = node.DummyContrasts.Contrasts{iCon};
      [cdtName, regIdx] = getRegressorIdx(cdtName, SPM);

      switch lower(level)

        case 'subject'

          C = newContrast(SPM, cdtName);
          C.C(end, regIdx) = 1;
          [contrasts, counter] = appendContrast(contrasts, C, counter);
          clear regIdx;

        case 'run'

          % For each run of each condition, create a seperate contrast
          regIdx = find(regIdx);
          for iReg = 1:length(regIdx)

            C = newContrast(SPM, [cdtName, '_', num2str(iReg)]);

            % give each event a value of 1
            C.C(end, regIdx(iReg)) = 1;
            [contrasts, counter] = appendContrast(contrasts, C, counter);

          end

          clear regIdx;

        otherwise
          warning('only Run and Subject node level supported');
      end

    end

  end

end

function [contrasts, counter] = specifySubLvlContrasts(contrasts, node, counter, SPM)

  if ~isfield(node, 'Contrasts')
    return
  end

  % then the contrasts that involve contrasting conditions
  % amongst themselves or something inferior to baseline
  for iCon = 1:length(node.Contrasts)

    if ~isTtest(node.Contrasts(iCon))
      continue
    end

    if ~isfield(node.Contrasts(iCon), 'Weights')
      msg = 'weightless contrasts not supported yet';
      errorHandling(mfilename(), 'notImplemented', msg, true, true);
      continue
    end

    C = newContrast(SPM, node.Contrasts(iCon).Name);

    for iCdt = 1:length(node.Contrasts(iCon).ConditionList)

      % get regressors index corresponding to the HRF of that condition
      cdtName = node.Contrasts(iCon).ConditionList{iCdt};
      [~, regIdx, status] = getRegressorIdx(cdtName, SPM);

      if ~status
        break
      end

      % give them the value specified in the model
      C.C(end, regIdx) = node.Contrasts(iCon).Weights(iCdt);

      clear regIdx;

    end

    % do not create this contrast if a condition is missing
    if ~status
      disp(node.Contrasts(iCon).ConditionList);
      msg = sprintf('Skipping contrast %s: runs are missing condition %s', ...
                    node.Contrasts(iCon).Name, cdtName);
      errorHandling(mfilename(), 'runMissingCondition', msg, true, true);
    end
    [contrasts, counter] = appendContrast(contrasts, C, counter);

  end

end

function [contrasts, counter] = specifyRunLvlContrasts(contrasts, node, counter, SPM)

  if ~isfield(node, 'Contrasts')
    return
  end

  % then the contrasts that involve contrasting conditions
  % amongst themselves or something inferior to baseline
  for iCon = 1:length(node.Contrasts)

    if ~isTtest(node.Contrasts(iCon))
      continue
    end

    if ~isfield(node.Contrasts(iCon), 'Weights')
      msg = 'weightless contrasts not supported yet';
      errorHandling(mfilename(), 'notImplemented', msg, true, true);
      continue
    end

    % get regressors index corresponding to the HRF of that condition
    for iCdt = 1:length(node.Contrasts(iCon).ConditionList)
      cdtName = node.Contrasts(iCon).ConditionList{iCdt};
      [~, regIdx{iCdt}] = getRegressorIdx(cdtName, SPM);
      regIdx{iCdt} = find(regIdx{iCdt});
    end

    nbRuns = unique(cellfun(@numel, regIdx));

    if length(nbRuns) > 1
      disp(node.Contrasts(iCon).ConditionList);
      msg = sprintf('Skipping contrast %s: runs are missing condition %s', ...
                    node.Contrasts(iCon).Name, cdtName);
      errorHandling(mfilename(), 'runMissingCondition', msg, true, true);

      continue
    end

    % give them the value specified in the model
    for iRun = 1:nbRuns

      C = newContrast(SPM, [node.Contrasts(iCon).Name, '_', num2str(iRun)]);

      for iCdt = 1:length(node.Contrasts(iCon).ConditionList)
        C.C(end, regIdx{iCdt}(iRun)) = node.Contrasts(iCon).Weights(iCdt);
      end

      [contrasts, counter] = appendContrast(contrasts, C, counter);

    end
    clear regIdx;

  end

end

function status = isTtest(structure)
  status = true;
  if isfield(structure, 'Test') && ~strcmp(structure.Test, 't')
    status = false;
    msg = 'Only t test supported for contrasts';
    errorHandling(mfilename(), 'notImplemented', msg, true, true);
  end
end

function C = newContrast(SPM, conName)
  C.C = zeros(1, size(SPM.xX.X, 2));
  C.name = conName;
end

function [contrasts, counter] = appendContrast(contrasts, C, counter)
  counter = counter + 1;
  contrasts(counter).C = C.C;
  contrasts(counter).name = C.name;
end

function  [cdtName, regIdx, status] = getRegressorIdx(cdtName, SPM)
  % get regressors index corresponding to the HRF of of a condition

  % get condition name
  cdtName = strrep(cdtName, 'trial_type.', '');

  % get regressors index corresponding to the HRF of that condition
  regIdx = strfind(SPM.xX.name', [' ' cdtName '*bf(1)']);
  regIdx = ~cellfun('isempty', regIdx);  %#ok<*STRCL1>

  status = checkRegressorFound(regIdx, cdtName);

end

function status = checkRegressorFound(regIdx, cdtName)
  status = true;
  regIdx = find(regIdx);
  if all(~regIdx)
    status = false;
    msg = sprintf('No regressor found for condition "%s"', cdtName);
    errorHandling(mfilename(), 'noRegressorFound', msg, true, true);
  end
end
