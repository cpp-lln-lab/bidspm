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

  % (C) Copyright 2019 bidspm developers

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
