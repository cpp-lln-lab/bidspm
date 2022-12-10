function eventSpecification = getEventSpecificationRoiGlm(varargin)
  %
  %
  % USAGE::
  %
  %   event_specification = getEventSpecificationRoiGlm(SPM_file, model_file)
  %
  % :param SPM_file: obligatory argument. fullpath to SPM.mat
  % :type  SPM_file: path
  %
  % :param model_file: obligatory argument. fullpath to BIDS stats model
  % :type  model_file: fullpath
  %
  % :returns: - :event_specification: (structure) (dimension)
  %
  % event_specification(1).name 'F1'
  % event_specification(1).event_spec [1;1]
  % event_specification(1).duration 0
  %
  % Will use the run level contrasts but falls back on the subject level,
  % if we do not find any contrasts at the run level.
  %
  % ASSUMPTION:
  %
  % That all events that are "pooled" together have more or less the same duration.
  % No check in place to warn if that is not the case.
  %
  % See also: event_fitted, event_signal
  %

  % (C) Copyright 2022 bidspm developers

  args = inputParser;

  isFile = @(x) exist(x, 'file') == 2;

  addRequired(args, 'SPM', isFile);
  addRequired(args, 'modelFile', isFile);

  parse(args, varargin{:});

  SPM = args.Results.SPM;
  modelFile = args.Results.modelFile;

  load(SPM);

  bm = BidsModel('file', modelFile);
  bm.getModelType();

  % We focus on the run level but fall back on the subject level
  % if we do not find any contrasts at the run level
  node = bm.get_nodes('Level', 'run');
  if ~isfield(node, 'DummyContrasts') || ~isfield(node, 'Contrasts')
    node = bm.get_nodes('Level', 'subject');
  end

  eventSpecification = struct('name', '', 'eventSpec', [], 'duration', []);

  eventSpecification = getEventSpecForDummyContrasts(eventSpecification, node, SPM);

  eventSpecification = getEventSpecForContrasts(eventSpecification, node, SPM);

end

function eventSpec = getEventSpecForDummyContrasts(eventSpec, node, SPM)

  if ~isfield(node, 'DummyContrasts') || ~isTtest(node.DummyContrasts)
    return
  end

  specCounter = numel(eventSpec);

  % contrasts to compute automatically against baseline
  for iCon = 1:length(node.DummyContrasts.Contrasts)

    cdtName = node.DummyContrasts.Contrasts{iCon};

    thisContrastEventSpec = returnThisContrastEventSpec(cdtName, SPM);

    if ~isempty(thisContrastEventSpec.eventSpec)

      tokens = regexp(cdtName, '\.', 'split');
      if numel(tokens) > 1
        cdtName = tokens{2};
      else
        cdtName = tokens{1};
      end

      eventSpec(specCounter).name = cdtName;
      eventSpec(specCounter).eventSpec = thisContrastEventSpec.eventSpec;
      eventSpec(specCounter).duration = mean(thisContrastEventSpec.duration);

      specCounter = specCounter + 1;

    end

  end

end

function eventSpec = getEventSpecForContrasts(eventSpec, node, SPM)

  if ~isfield(node, 'Contrasts')
    return
  end

  specCounter = numel(eventSpec) + 1;

  for iCon = 1:length(node.Contrasts)

    thisContrast = node.Contrasts{iCon};

    % only check contrasts against baseline
    % (no comparing conditions - YET)
    if isTtest(thisContrast) && isContrastAgainstBaseline(thisContrast)

      conditionList = thisContrast.ConditionList;

      thisContrastEventSpec = returnThisContrastEventSpec(conditionList, SPM);

      if ~isempty(thisContrastEventSpec.eventSpec)

        eventSpec(specCounter).name = thisContrast.Name;
        eventSpec(specCounter).eventSpec = thisContrastEventSpec.eventSpec;
        eventSpec(specCounter).duration = mean(thisContrastEventSpec.duration);

        specCounter = specCounter + 1;

      end

    end

  end

end

function thisContrastEventSpec = returnThisContrastEventSpec(conditionList, SPM)

  if ischar(conditionList)
    conditionList = {conditionList};
  end

  nbRuns = numel(SPM.Sess);

  thisContrastEventSpec = struct('eventSpec', [], 'duration', []);

  for iCdt = 1:numel(conditionList)

    tokens = regexp(conditionList{iCdt}, '\.', 'split');
    if numel(tokens) > 1
      cdtName = tokens{2};
    else
      cdtName = tokens{1};
    end

    for iRun = 1:nbRuns

      tmp = cat(2, SPM.Sess(iRun).U(:).name);

      conditionPresent = ismember(tmp, cdtName);

      if any(conditionPresent)

        thisContrastEventSpec.eventSpec(:, end + 1) = [iRun; find(conditionPresent)];

        meanDuration = mean(SPM.Sess(iRun).U(conditionPresent).dur);
        thisContrastEventSpec.duration(:, end + 1) = meanDuration;

      end

    end

  end

end

function status = isContrastAgainstBaseline(contrast)
  %
  %  only includes contrast with all weights > 0 and all equal to each other
  %

  % (C) Copyright 2022 Remi Gau

  status = true;

  if any(contrast.Weights < 0) || ~(numel(unique(contrast.Weights)) == 1)

    status = false;
    msg = 'Only contrasts against baseline supported';
    notImplemented(mfilename(), msg);

  end

end
