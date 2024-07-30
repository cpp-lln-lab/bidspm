function contrasts = specifyContrasts(model, SPM, nodeName)
  %
  % Specifies the contrasts for run, session and subject level nodes.
  %
  % USAGE::
  %
  %   contrasts = specifyContrasts(model, SPM)
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
  % :return: :contrasts: (structure)
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
    id = 'wrongStatsModel';
    msg = 'No node in the model';
    logger('WARNING', msg, 'id', id, 'filename', mfilename());
  end

  if nargin < 3 || isempty(nodeName)
    nodeList = getNodeList(model);
  else
    nodeList = model.get_nodes('Name', nodeName);
  end

  model.SPM = SPM;

  % check all the nodes specified in the model
  for iNode = 1:length(nodeList)

    node = nodeList(iNode);

    if iscell(node)
      node = node{1};
    end

    if ismember(lower(node.Level), {'session', 'subject'}) && ~model.validateGroupBy(node.Name)
      continue
    end

    [contrasts, counter] = specifyDummyContrasts(model, node, contrasts, counter);

    switch lower(node.Level)

      case 'run'
        [contrasts, counter] = specifyRunLvlContrasts(model, node, contrasts, counter);

      case 'session'
        [contrasts, counter] = specifySessionLvlContrasts(model, node, contrasts, counter);

      case 'subject'
        [contrasts, counter] = specifySubLvlContrasts(model, node, contrasts, counter);

    end

  end

  if numel(contrasts) == 1 && isempty(contrasts.C)
    msg = 'No contrast to build.';
    id = 'noContrast';
    logger('WARNING', msg, 'id', id, 'filename', mfilename());
    return
  end

  contrasts = removeDuplicates(contrasts);

end

function nodeList = getNodeList(bm)
  %
  %  Return all the nodes present in the bids stats model
  %  - if there is only one,
  %  - or as long as they are included in some edges.
  %
  nodeList = {};

  if isempty(bm.Nodes)
    return
  end

  if numel(bm.Nodes) == 1
    if iscell(bm.Nodes)
      nodeList = bm.Nodes{1};
    else
      % should not be necessary
      % but in case nodes were not coerced to cell
      % during test set up
      nodeList = bm.Nodes(1);
    end
    return
  end

  if isempty(bm.Edges)
    bm = bm.get_edges_from_nodes();
  end

  for i = 1:numel(bm.Edges)
    nodeList{end + 1} = bm.Edges{i}.Source; %#ok<*AGROW>
    nodeList{end + 1} = bm.Edges{i}.Destination;
  end
  nodeList = unique(nodeList);
  for iNode = 1:length(nodeList)
    nodeList{iNode} = bm.get_nodes('Name', nodeList{iNode});
  end

end

function contrasts = removeDuplicates(contrasts)
  % remove all but one contrast that have the same name, vector and type

  tmp = contrasts;

  for i = 1:numel(contrasts)

    name = contrasts(i).name;
    if sum(ismember({contrasts.name}, name)) == 1
      continue
    end

    duplicates = find(~cellfun('isempty', regexp({tmp.name}, name, 'match')));

    if numel(unique({tmp(duplicates).type})) > 1
      continue
    end

    vectors = cat(1, tmp(duplicates).C);

    if size(unique(vectors, 'rows'), 1) > 1
      for iDupe = 1:numel(duplicates)
        disp(tmp(duplicates(iDupe)));
      end
      msg = 'there are contrasts with the same name but different vector.';
      id = 'duplicateContrasts';
      logger('WARNING', msg, 'id', id, 'filename', mfilename());
      continue
    end

    tmp(duplicates(2:end)) = [];

  end

  contrasts = tmp;

end

function [contrasts, counter] = specifyRunLvlContrasts(model, node, contrasts, counter)
  %
  % For the contrasts that involve contrasting conditions amongst themselves
  % or something inferior to baseline
  %

  if ~isfield(node, 'Contrasts')
    return
  end

  for iCon = 1:length(node.Contrasts)

    thisContrast = checkContrast(model, node, iCon);

    if isempty(thisContrast) || strcmp(thisContrast.Test, 'pass')
      continue
    end

    conditionList = thisContrast.ConditionList;

    for iCdt = 1:length(conditionList)
      cdtName = conditionList{iCdt};
      [~, regIdx{iCdt}] = getRegressorIdx(cdtName, model.SPM);
      regIdx{iCdt} = find(regIdx{iCdt});
    end

    % make sure all runs have all conditions
    % TODO possibly only skip the runs that are missing some conditions and not
    % all of them.
    nbRuns = unique(cellfun(@numel, regIdx));

    if length(nbRuns) > 1
      msg = sprintf('Skipping contrast %s: runs are missing condition %s', ...
                    thisContrast.Name, cdtName);
      id = 'runMissingCondition';
      logger('WARNING', msg, 'id', id, 'filename', mfilename());

      continue
    end

    for iRun = 1:nbRuns

      % Use the SPM Sess index for the contrast name
      iSess = getSessionForRegressorNb(regIdx{1}(iRun), model.SPM);

      contrastName = constructContrastNameFromBidsEntity(thisContrast.Name, model.SPM, iSess);
      C = newContrast(model.SPM, contrastName, thisContrast.Test, conditionList);

      for iCdt = 1:length(conditionList)

        if strcmp(thisContrast.Test, 't')
          C.C(end, regIdx{iCdt}(iRun)) = thisContrast.Weights(iCdt);

        elseif strcmp(thisContrast.Test, 'F')
          for i = 1:size(thisContrast.Weights, 1)
            C.C(i, regIdx{iCdt}(iRun)) = thisContrast.Weights(i, iCdt);
          end

        end

      end

      [contrasts, counter] = appendContrast(contrasts, C, counter, thisContrast.Test);

    end

    clear regIdx;

  end

end
