function contrasts = specifyContrasts(SPM, model, nodeName)
  %
  % Specifies the first level contrasts
  %
  % USAGE::
  %
  %   contrasts = specifyContrasts(SPM, model)
  %
  % :param SPM: content of SPM.mat
  % :type SPM: structure
  %
  % :param model:
  % :type model: bids model object
  %
  % :param nodeName: name of the node to return name of
  % :type nodeName: char
  %
  % :returns: - :contrasts: (structure)
  %
  % To know the names of the columns of the design matrix, type :
  % ``strvcat(SPM.xX.name)``
  %
  %
  % See also: setBatchSubjectLevelContrasts, setBatchGroupLevelContrasts
  %
  %
  % (C) Copyright 2019 CPP_SPM developers

  % TODO refactor code duplication between run level and subject level

  % TODO refactor with some of the functions from the bids-model folder ?

  contrasts = struct('C', [], 'name', []);
  counter = 0;

  if numel(model.Nodes) < 1
    errorHandling(mfilename(), 'wrongStatsModel', 'No node in the model', true, true);
  end

  if nargin < 3 || isempty(nodeName)
    nodeList = model.get_nodes();
  else
    nodeList = model.get_nodes('Name', nodeName);
  end

  % check all the nodes specified in the model
  for iNode = 1:length(nodeList)

    node = nodeList(iNode);

    if iscell(node)
      node = node{1};
    end

    [contrasts, counter] = specifyDummyContrasts(contrasts, node, counter, SPM, model);

    switch lower(node.Level)

      case 'run'

        [contrasts, counter] = specifyRunLvlContrasts(contrasts, node, counter, SPM);

      case 'subject'

        if ~checkGroupBy(node)
          continue
        end

        [contrasts, counter] = specifySubLvlContrasts(contrasts, node, counter, SPM);

    end

  end

  if numel(contrasts) == 1 && isempty(contrasts.C)
    msg = 'No contrast to build';
    errorHandling(mfilename(), 'noContrast', msg, true, true);
  end

end

function [contrasts, counter] = specifyDummyContrasts(contrasts, node, counter, SPM, model)

  if ~isfield(node, 'DummyContrasts')
    return
  end

  level = lower(node.Level);

  if ismember(level, {'session'})
    notImplemented(mfilename(), ...
                   'Specifying dummy contrasts for session level Node not implemented.', ...
                   true);
    return
  end

  if ismember(level, {'dataset'})
    % see setBatchGroupLevelContrasts
    return
  end

  if strcmp(level, 'subject') && ~checkGroupBy(node)
    % only "GroupBy": ["contrast", "subject"] supported
    return
  end

  testType = 't';
  if ~isTtest(node.DummyContrasts)
    notImplemented(mfilename(), ...
                   'Only t test implemented for DummyContrasts', ...
                   true);
    return
  end

  %% DummyContrasts that are explicitly mentioned or based on DummyContrasts from previous level
  dummyContrastsList = getDummyContrastsList(node, model);

  for iCon = 1:length(dummyContrastsList)

    cdtName = dummyContrastsList{iCon};
    [cdtName, regIdx] = getRegressorIdx(cdtName, SPM);

    switch level

      case 'subject'

        C = newContrast(SPM, cdtName, testType);
        C.C(end, regIdx) = 1;
        [contrasts, counter] = appendContrast(contrasts, C, counter, testType);
        clear regIdx;

      case 'run'

        % For each run of each condition, create a seperate contrast
        regIdx = find(regIdx);
        for iReg = 1:length(regIdx)

          % Use the SPM Sess index for the contrast name
          iSess = getSessionForRegressorNb(regIdx(iReg), SPM);

          C = newContrast(SPM, [cdtName, '_', num2str(iSess)], testType);

          % give each event a value of 1
          C.C(end, regIdx(iReg)) = 1;
          [contrasts, counter] = appendContrast(contrasts, C, counter, testType);

        end

        clear regIdx;

    end

  end

  %% set up DummyContrasts at subject level that are based on Contrast from previous level
  contrastsList = {};
  if ~isfield(node.DummyContrasts, 'Contrasts')
    % try to grab ContrastsList from design matrix or from previous Node
    contrastsList = getContrastsList(node, model);
  end

  for iCon = 1:length(contrastsList)

    this_contrast = contrastsList{iCon};

    if isempty(this_contrast) || strcmp(this_contrast.Test, 'pass')
      continue
    end

    switch level

      case 'subject'

        C = newContrast(SPM, this_contrast.Name, this_contrast.Test);

        conditionList = this_contrast.ConditionList;

        % get regressors index corresponding to the HRF of that condition
        for iCdt = 1:length(conditionList)

          cdtName = conditionList{iCdt};

          [~, regIdx{iCdt}] = getRegressorIdx(cdtName, SPM);

          regIdx{iCdt} = find(regIdx{iCdt});

          C.C(end, regIdx{iCdt}) = this_contrast.Weights(iCdt);

        end
        clear regIdx;

      otherwise
        % not implemented

    end

    [contrasts, counter] = appendContrast(contrasts, C, counter, this_contrast.Test);

  end

end

function [contrasts, counter] = specifyRunLvlContrasts(contrasts, node, counter, SPM)
  %
  % For the contrasts that involve contrasting conditions
  % amongst themselves or something inferior to baseline

  if ~isfield(node, 'Contrasts')
    return
  end

  for iCon = 1:length(node.Contrasts)

    this_contrast = checkContrast(node, iCon);

    if isempty(this_contrast) || strcmp(this_contrast.Test, 'pass')
      continue
    end

    conditionList = this_contrast.ConditionList;

    for iCdt = 1:length(conditionList)
      cdtName = conditionList{iCdt};
      [~, regIdx{iCdt}] = getRegressorIdx(cdtName, SPM);
      regIdx{iCdt} = find(regIdx{iCdt});
    end

    % make sure all runs have all conditions
    % TODO possibly only skip the runs that are missing some conditions and not
    % all of them.
    nbRuns = unique(cellfun(@numel, regIdx));

    if length(nbRuns) > 1
      msg = sprintf('Skipping contrast %s: runs are missing condition %s', ...
                    this_contrast.Name, cdtName);
      errorHandling(mfilename(), 'runMissingCondition', msg, true, true);

      continue
    end

    for iRun = 1:nbRuns

      % Use the SPM Sess index for the contrast name
      iSess = getSessionForRegressorNb(regIdx{1}(iRun), SPM);

      C = newContrast(SPM, ...
                      [this_contrast.Name, '_', num2str(iSess)], ...
                      this_contrast.Test, ...
                      conditionList);

      for iCdt = 1:length(conditionList)

        if strcmp(this_contrast.Test, 't')
          C.C(end, regIdx{iCdt}(iRun)) = this_contrast.Weights(iCdt);

        elseif strcmp(this_contrast.Test, 'F')
          C.C(iCdt, regIdx{iCdt}(iRun)) = this_contrast.Weights(iCdt);

        end

      end

      [contrasts, counter] = appendContrast(contrasts, C, counter, this_contrast.Test);

    end

    clear regIdx;

  end

end

function [contrasts, counter] = specifySubLvlContrasts(contrasts, node, counter, SPM)

  if ~isfield(node, 'Contrasts')
    return
  end

  % only averaging run level contrasts supported for now.
  assert(node.Model.X == 1);

  % then the contrasts that involve contrasting conditions
  % amongst themselves or something inferior to baseline
  for iCon = 1:length(node.Contrasts)

    this_contrast = checkContrast(node, iCon);

    if isempty(this_contrast) || strcmp(this_contrast.Test, 'pass')
      continue
    end

    conditionList = this_contrast.ConditionList;

    C = newContrast(SPM, this_contrast.Name, this_contrast.Test, conditionList);

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
      errorHandling(mfilename(), 'runMissingCondition', msg, true, true);

    else
      [contrasts, counter] = appendContrast(contrasts, C, counter, this_contrast.Test);

    end

  end

end

function iSess = getSessionForRegressorNb(regIdx, SPM)
  % Use the SPM Sess index for the contrast name
  % TODO could be optimized
  for iSess = 1:numel(SPM.Sess)
    if ismember(regIdx, SPM.Sess(iSess).col)
      break
    end
  end
end

function C = newContrast(SPM, conName, type, conditionList)
  switch type
    case 't'
      C.C = zeros(1, size(SPM.xX.X, 2));
    case 'F'
      C.C = zeros(numel(conditionList), size(SPM.xX.X, 2));
  end
  C.name = conName;
end

function [contrasts, counter] = appendContrast(contrasts, C, counter, type)
  counter = counter + 1;
  contrasts(counter).type = type;
  contrasts(counter).C = C.C;
  contrasts(counter).name = C.name;
end
