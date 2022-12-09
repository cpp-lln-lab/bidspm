function [contrasts, counter] = specifyDummyContrasts(contrasts, node, counter, SPM, model)
  %
  %
  %
  % USAGE::
  %
  %   [contrasts, counter] = specifyDummyContrasts(contrasts, node, counter, SPM, model)
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

  level = lower(node.Level);

  if ismember(level, {'session'})
    notImplemented(mfilename()(), ...
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
    notImplemented(mfilename()(), ...
                   'Only t test implemented for DummyContrasts', ...
                   true);
    return
  end

  %% DummyContrasts that are explicitly mentioned or based on DummyContrasts from previous level
  dummyContrastsList = getDummyContrastsList(node, model);

  for iCon = 1:length(dummyContrastsList)

    cdtName = dummyContrastsList{iCon};

    cdtName = dealWithGlobPattern(cdtName);

    [cdtName, regIdx] = getRegressorIdx(cdtName, SPM);

    switch level

      case 'subject'

        C = newContrast(SPM, cdtName, testType);
        C.C(end, regIdx) = 1;
        [contrasts, counter] = appendContrast(contrasts, C, counter, testType);
        clear regIdx;

      case 'run'

        % For each run of each condition, create a separate contrast
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
  if ~isfield(node.DummyContrasts, 'Contrasts') % && strcmp(level, 'run')
    % try to grab ContrastsList from design matrix or from previous Node
    if strcmp(level, 'run')
      contrastsList = getContrastsList(node, model);
    else
      contrastsList = getContrastsListFromSource(node, model);
    end
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
