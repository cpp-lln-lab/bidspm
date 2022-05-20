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

    [contrasts, counter] = specifylDummyContrasts(contrasts, node, counter, SPM, model);

    switch lower(node.Level)

      case 'run'

        [contrasts, counter] = specifyRunLvlContrasts(contrasts, node, counter, SPM);

      case 'subject'

        if ~checkGroupBy(node)
          continue
        end

        [contrasts, counter] = specifySubLvlContrasts(contrasts, node, counter, SPM, model);

    end

  end

  if numel(contrasts) == 1 && isempty(contrasts.C)
    msg = 'No contrast to build';
    errorHandling(mfilename(), 'noContrast', msg, false, true);
  end

end

function status = checkGroupBy(node)
  status = true;
  node.GroupBy = sort(node.GroupBy);
  if not(all([strcmp(node.GroupBy{1}, 'contrast') strcmp(node.GroupBy{2}, 'subject')]))
    status = false;
    notImplemented(mfilename, ...
                   'only "GroupBy": ["contrast", "subject"] supported Subject node level', ...
                   true);
  end
end

function [contrasts, counter] = specifylDummyContrasts(contrasts, node, counter, SPM, model)

  if ~isfield(node, 'DummyContrasts')
    return
  end

  level = lower(node.Level);

  if ismember(level, {'session', 'dataset'})
    % not implemented
    return
  end

  if strcmp(level, 'subject') && ~checkGroupBy(node)
    % only "GroupBy": ["contrast", "subject"] supported
    return
  end

  if ~isTtest(node.DummyContrasts)
    notImplemented(mfilename(), ...
                   'Only t test implemented for DummyContrasts', ...
                   true);
    return
  end

  DummyContrastsList = {};
  ContrastsList = {};

  if isfield(node.DummyContrasts, 'Contrasts')

    DummyContrastsList = node.DummyContrasts.Contrasts;

  else

    % try to grab ContrastsList from design matrix

    switch level

      case 'run'
        % TODO this assumes "GroupBy": ["run", "subject"] or ["run", "session", "subject"]
        DummyContrastsList = node.Model.X;

      case 'subject'

        % TODO
        % assumes "GroupBy": ["contrast", "subject"]
        % assumes node.Model.X == 1

        % TODO transfer to BIDS model as a get_source method
        if ~isfield(model, 'Edges') || isempty(model.Edges)
          model = model.get_edges_from_nodes;
        end
        for i = 1:numel(model.Edges)
          if strcmp(model.Edges{i}.Destination, node.Name)
            source = model.Edges{i}.Source;
            break
          end
        end

        sourceNode = model.get_nodes('Name', source);

        % TODO transfer to BIDS model as a get_contrasts_list method

        if iscell(sourceNode)
          sourceNode = sourceNode{1};
          if isfield(sourceNode.DummyContrasts, 'Contrasts')
            DummyContrastsList = sourceNode.DummyContrasts.Contrasts;
          end
          if isfield(sourceNode, 'Contrasts')
            for i = 1:numel(sourceNode.Contrasts)
              ContrastsList{end + 1} = checkContrast(sourceNode, i);
            end
          end
        end

    end

  end

  % first the contrasts to compute automatically against baseline
  for iCon = 1:length(DummyContrastsList)

    cdtName = DummyContrastsList{iCon};
    [cdtName, regIdx] = getRegressorIdx(cdtName, SPM);

    switch level

      case 'subject'

        C = newContrast(SPM, cdtName);
        C.C(end, regIdx) = 1;
        [contrasts, counter] = appendContrast(contrasts, C, counter);
        clear regIdx;

      case 'run'

        % For each run of each condition, create a seperate contrast
        regIdx = find(regIdx);
        for iReg = 1:length(regIdx)

          % Use the SPM Sess index for the contrast name
          % TODO could be optimized
          for iSess = 1:numel(SPM.Sess)
            if ismember(regIdx(iReg), SPM.Sess(iSess).col)
              break
            end
          end

          C = newContrast(SPM, [cdtName, '_', num2str(iSess)]);

          % give each event a value of 1
          C.C(end, regIdx(iReg)) = 1;
          [contrasts, counter] = appendContrast(contrasts, C, counter);

        end

        clear regIdx;

    end

  end

  % set up DummyContrasts at subject level
  % that are based on contrast from previous level
  for iCon = 1:length(ContrastsList)

    this_contrast = ContrastsList{iCon};

    switch level

      case 'subject'

        C = newContrast(SPM, this_contrast.Name);

        ConditionList = this_contrast.ConditionList;

        % get regressors index corresponding to the HRF of that condition
        for iCdt = 1:length(ConditionList)

          cdtName = ConditionList{iCdt};

          [~, regIdx{iCdt}] = getRegressorIdx(cdtName, SPM);

          regIdx{iCdt} = find(regIdx{iCdt});

          C.C(end, regIdx{iCdt}) = this_contrast.Weights(iCdt);

        end
        clear regIdx;

    end

    [contrasts, counter] = appendContrast(contrasts, C, counter);

  end

end

function [contrasts, counter] = specifySubLvlContrasts(contrasts, node, counter, SPM, model)

  if ~isfield(node, 'Contrasts')
    return
  end

  % only averaging run level contrasts supported for now.
  assert(node.Model.X == 1);

  % then the contrasts that involve contrasting conditions
  % amongst themselves or something inferior to baseline
  for iCon = 1:length(node.Contrasts)

    source = mode.Edges;

    this_contrast = checkContrast(node, iCon);

    C = newContrast(SPM, this_contrast.Name);

    for iCdt = 1:length(this_contrast.ConditionList)

      % get regressors index corresponding to the HRF of that condition
      cdtName = this_contrast.ConditionList{iCdt};
      [~, regIdx, status] = getRegressorIdx(cdtName, SPM);

      if ~status
        break
      end

      % give them the value specified in the model
      C.C(end, regIdx) = this_contrast.Weights(iCdt);

      clear regIdx;

    end

    % do not create this contrast if a condition is missing
    if ~status
      msg = sprintf('Skipping contrast %s: runs are missing condition %s', ...
                    this_contrast.Name, cdtName);
      errorHandling(mfilename(), 'runMissingCondition', msg, true, true);
    else
      [contrasts, counter] = appendContrast(contrasts, C, counter);
    end

  end

end

function contrast = checkContrast(node, iCon)
  %
  % put some of that in bids.Model

  if ~isTtest(node.Contrasts(iCon))
    notImplemented(mfilename(), ...
                   'Only t test implemented for DummyContrasts', ...
                   true);
  end

  contrast = node.Contrasts(iCon);
  if iscell(contrast)
    contrast = contrast{1};
  end

  if ~isfield(contrast, 'Weights')
    msg = sprintf('No weights specified for Contrast %s of Node %s', ...
                  node.Contrasts(iCon).Name, node.Name);
    errorHandling(mfilename, 'weightsRequired', msg, false);
  end

  if numel(contrast.Weights) ~= numel(contrast.ConditionList)
    msg = sprintf('Number of Weights and Conditions unequal for Contrast %s of Node %s', ...
                  node.Contrasts(iCon).Name, node.Name);
    errorHandling(mfilename, 'numelWeightsConditionMismatch', msg, false);
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
      msg = sprintf('No weights specified for for Contrast %s of Node %s', ...
                    node.Contrasts(iCon).Name, node.Name);
      errorHandling(mfilename, 'weightsRequired', msg, false);
    end

    % get regressors index corresponding to the HRF of that condition
    ConditionList = node.Contrasts(iCon).ConditionList;
    for iCdt = 1:length(ConditionList)
      cdtName = ConditionList{iCdt};
      [~, regIdx{iCdt}] = getRegressorIdx(cdtName, SPM);
      regIdx{iCdt} = find(regIdx{iCdt});
    end

    % make sure all runs have all conditions
    % TODO possibly only skip the runs that are missing some conditions and not
    % all of them.
    nbRuns = unique(cellfun(@numel, regIdx));

    if length(nbRuns) > 1
      msg = sprintf('Skipping contrast %s: runs are missing condition %s', ...
                    node.Contrasts(iCon).Name, cdtName);
      errorHandling(mfilename(), 'runMissingCondition', msg, true, true);

      continue
    end

    % give them the value specified in the model
    for iRun = 1:nbRuns

      % Use the SPM Sess index for the contrast name
      % TODO could be optimized
      for iSess = 1:numel(SPM.Sess)
        if ismember(regIdx{1}(iRun), SPM.Sess(iSess).col)
          break
        end
      end

      C = newContrast(SPM, [node.Contrasts(iCon).Name, '_', num2str(iSess)]);

      for iCdt = 1:length(node.Contrasts(iCon).ConditionList)
        C.C(end, regIdx{iCdt}(iRun)) = node.Contrasts(iCon).Weights(iCdt);
      end

      [contrasts, counter] = appendContrast(contrasts, C, counter);

    end
    clear regIdx;

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
    msg = sprintf('No regressor found for condition ''%s''', cdtName);
    errorHandling(mfilename(), 'missingRegressor', msg, true, true);
  end
end
