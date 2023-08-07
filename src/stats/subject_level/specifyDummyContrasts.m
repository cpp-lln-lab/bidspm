function [contrasts, counter] = specifyDummyContrasts(model, node, SPM, contrasts, counter)
  %
  % USAGE::
  %
  %   [contrasts, counter] = specifyDummyContrasts(model, node, SPM, contrasts, counter )
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
  % :param SPM: content of SPM.mat
  % :type  SPM: struct
  %
  % :param model:
  % :type  model: BidsModel object
  %
  %
  % See also: specifyContrasts
  %

  % (C) Copyright 2022 bidspm developers

  if ~isfield(node, 'DummyContrasts')
    return
  end

  if ismember(node.Level, {'session'}) && ~checkGroupBy(node)
    return
  end
  if strcmp(node.Level, 'subject') && ~checkGroupBy(node)
    return
  end
  if ismember(node.Level, {'dataset'})
    % see setBatchGroupLevelContrasts
    return
  end

  SPM = labelSpmSessWithBidsSesAndRun(SPM);

  [contrasts, counter] = addExplicitDummyContrasts(model, node, SPM, contrasts, counter);

  %% DummyContrasts at session / subject level that are based on Contrast from previous level

  contrastsList = {};
  if ~isfield(node.DummyContrasts, 'Contrasts') % && strcmp(level, 'run')
    % try to grab ContrastsList from design matrix or from previous Node
    if strcmpi(node.Level, 'run')
      contrastsList = getContrastsList(model, node);
    else
      contrastsList = getContrastsFromParentNode(model, node);
    end
  end

  for iCon = 1:length(contrastsList)

    thisContrast = contrastsList{iCon};

    if isempty(thisContrast) || strcmp(thisContrast.Test, 'pass')
      continue
    end

    switch lower(node.Level)

      case 'session'
        bidsSessions = unique({SPM.Sess.ses});
        for iSes = 1:numel(bidsSessions)
          C = newContrast(SPM, ...
                          [thisContrast.Name, '_ses-', bidsSessions{iSes}], ...
                          thisContrast.Test);
          conditionList = thisContrast.ConditionList;
          for iCdt = 1:length(conditionList)
            cdtName = conditionList{iCdt};
            [~, regIdx] = getRegressorIdx(cdtName, SPM, bidsSessions{iSes});
            C.C(end, regIdx) = thisContrast.Weights(iCdt);
          end
          [contrasts, counter] = appendContrast(contrasts, C, counter, thisContrast.Test);
        end

      case 'subject'
        C = addSubjectLevelContrastBasedOnPreviousLevels(SPM, thisContrast);
        [contrasts, counter] = appendContrast(contrasts, C, counter, thisContrast.Test);

      otherwise
        % not implemented

    end

  end

end

function  C = addSubjectLevelContrastBasedOnPreviousLevels(SPM, thisContrast)

  C = newContrast(SPM, thisContrast.Name, thisContrast.Test);

  conditionList = thisContrast.ConditionList;

  % get regressors index corresponding to the HRF of that condition
  for iCdt = 1:length(conditionList)

    cdtName = conditionList{iCdt};

    [~, regIdx{iCdt}] = getRegressorIdx(cdtName, SPM);
    regIdx{iCdt} = find(regIdx{iCdt});

    C.C(end, regIdx{iCdt}) = thisContrast.Weights(iCdt);

  end
  clear regIdx;

end

function [contrasts, counter] = addExplicitDummyContrasts(model, node, SPM, contrasts, counter)
  %
  % DummyContrasts explicitly mentioned or based on DummyContrasts from previous level
  %

  testType = 't';
  if ~isTtest(node.DummyContrasts)
    notImplemented(mfilename(), ...
                   'Only t test implemented for DummyContrasts');
    return
  end

  dummyContrastsList = getDummyContrastsList(model, node);

  for iCon = 1:length(dummyContrastsList)

    cdtName = dummyContrastsList{iCon};

    cdtName = dealWithGlobPattern(cdtName);

    [cdtName, regIdx] = getRegressorIdx(cdtName, SPM);

    switch lower(node.Level)

      case 'subject'

        C = newContrast(SPM, cdtName, testType);
        C.C(end, regIdx) = 1;
        [contrasts, counter] = appendContrast(contrasts, C, counter, testType);
        clear regIdx;

      case 'session'

        bidsSessions = unique({SPM.Sess.ses});
        for iSes = 1:numel(bidsSessions)
          C = newContrast(SPM, [cdtName, '_ses-', bidsSessions{iSes}], testType);
          [~, regIdx] = getRegressorIdx(cdtName, SPM, bidsSessions{iSes});
          C.C(end, regIdx) = 1;
          [contrasts, counter] = appendContrast(contrasts, C, counter, testType);
          clear regIdx;
        end

      case 'run'

        % For each run of each condition, create a separate contrast
        regIdx = find(regIdx);
        for iReg = 1:length(regIdx)

          % Use the SPM Sess index for the contrast name
          iSess = getSessionForRegressorNb(regIdx(iReg), SPM);

          contrastName = constructContrastNameFromBidsEntity(cdtName, SPM, iSess);
          C = newContrast(SPM, contrastName, testType);

          % give each event a value of 1
          C.C(end, regIdx(iReg)) = 1;
          [contrasts, counter] = appendContrast(contrasts, C, counter, testType);

        end

        clear regIdx;

      otherwise

    end

  end

end

function cdtName = dealWithGlobPattern(cdtName)
  % deal with any globbing search like 'face_familiar*'
  hasGlobPattern = ~cellfun('isempty', regexp({cdtName}, '\*|\?'));
  if hasGlobPattern

    tokens = regexp(cdtName, '\.', 'split');
    if numel(tokens) > 1
      cdtName = tokens{2};
    end
    pattern = strrep(cdtName, '*', '[\_\-0-9a-zA-Z]*');
    cdtName = strrep(pattern, '?', '[0-9a-zA-Z]?');
  end
end
